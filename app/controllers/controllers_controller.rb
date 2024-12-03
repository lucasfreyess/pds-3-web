class ControllersController < ApplicationController
  before_action :set_controller, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :authorize_user, only: [:show]
  #before_action :is_admin, only: [:new, :create]
  #before_action :is_not_admin

  # GET /controllers
  def index
    if current_user.is_admin
      @controllers = Controller.all
    else
      @controllers = Controller.where(user_id: current_user.id)
    end
  end

  # GET /controllers/available
  def available
    @controllers = Controller.where(user_id: nil)
  end

  # GET /controllers/:id
  def show
    @user = @controller.user
    if @user
      @model = @controller.user.model
    else
      @model = nil
    end

    topic = @controller.esp32_mac_address
    payload = { time: Time.current.strftime('%Y-%m-%d %H:%M:%S') }.to_json


    @lockers = @controller.lockers.order(:id)
    @connected = @controller.last_seen_at && (Time.current - @controller.last_seen_at) <= 10.minutes

    # si no se hace flash.now entonces el mensaje se muestra en la siguiente vista xd
    if @connected
      flash.now[:info] = "¡Conexión exitosa!"
    else
      flash.now[:warning] = "No se pudo conectar al controlador."
    end
  end

  require 'timeout'

  def verify_connection
    @controller = Controller.find(params[:id])

    begin
      # Establecer un timeout de 10 segundos
      Timeout.timeout(50) do
        # Publicar el mensaje MQTT para verificar conexión
        Rails.logger.debug "Llamando a MqttController#connection para el controlador #{@controller.id}"
        MqttController.new.connection(@controller)
        MqttController.new.subscribe_to_controller_connection(@controller)
      end

      flash[:info] = "Verificando conexión..."
      head :ok
    rescue Timeout::Error
      Rails.logger.error "Error de conexión MQTT: Tiempo de espera excedido"
      flash[:danger] = "El controlador tardó demasiado en responder. Verifica su estado."
      head :ok
    rescue StandardError => e
      Rails.logger.error "Error inesperado: #{e.message}"
      flash[:danger] = "Ocurrió un error inesperado. Intenta nuevamente más tarde."
      head :ok
    end
  end

  # GET /controllers/new
  def new
    @controller = Controller.new
    @controller.lockers.build
  end

  # POST /controllers
  def create
    Rails.logger.debug "PARAMS: #{params.inspect}"
    Rails.logger.debug "Controller params: #{params[:controller].inspect}"

    # Verifica si params[:controller] está como un hash o como un string
    if params[:controller].is_a?(Hash)
      Rails.logger.debug "controller params is a hash"
    else
      Rails.logger.debug "controller params is NOT a hash"
    end

    @controller = Controller.new(controller_params)
    locker_count = params[:locker_count].to_i.clamp(1, 4) # Aseguramos que sea entre 1 y 4

    if @controller.save
      current_lockers_count = @controller.lockers.count
      remaining_lockers = 4 - current_lockers_count

      if remaining_lockers > 0
        lockers_to_create = [locker_count, remaining_lockers].min  # Crea solo el número de lockers que falta

        Rails.logger.debug "Creating #{lockers_to_create} lockers..."

        # Crear lockers con nombres numéricos
        (1..lockers_to_create).each do |i|
          locker = @controller.lockers.create(name: "#{current_lockers_count + i}")
          if locker.persisted?
            Rails.logger.debug "Locker created: #{locker.name}"
          else
            Rails.logger.error "Error creating locker: #{locker.errors.full_messages.join(', ')}"
          end
        end

        #MQTT al crear un controlador
        MqttController.new.publish_controller_register(@controller)

        flash[:success] = "Controlador creado correctamente con #{lockers_to_create} lockers."
        redirect_to controllers_path
      else
        flash[:warning] = "Este controlador ya tiene el máximo de 4 casilleros."
        redirect_to controllers_path
      end
    else
      flash[:danger] = "Hubo un error al crear el controlador."
      render :new
    end
  end


  # PATCH /controllers/:id/assign_to_user
  def assign_to_user
    @controller = Controller.find(params[:id])

    puts @controller.inspect

    if @controller.update!(user_id: current_user.id)
      #regenerate_lockers_passwords tiene dentro suyo la publicacion de las
      #nuevas claves, junto con model_url (aunque no haya cambiado), a mqtt
      @controller.regenerate_lockers_passwords_if_model_changed
      flash[:success] = "Controlador asignado correctamente."
      redirect_to controllers_path#, notice: "Controlador asignado correctamente."
    else
      flash[:danger] = "Hubo un error al asignar el controlador."
      render :available_path#, alert: "Hubo un error al asignar el controlador."
    end
  end

  # PATCH /controllers/:id/unlink_from_user
  def unlink_from_user
    @controller = Controller.find(params[:id])

    if @controller.update!(user_id: nil)

      # Actualiza los correos de los lockers a vacío
      @controller.lockers.update_all(owner_email: "")

      flash[:notice] = "Controlador desasignado correctamente."
      redirect_to controllers_path#, notice: "Controlador desasignado correctamente."
    else
      flash[:danger] = "Hubo un error al desasignar el controlador."
      redirect_to controller_path(@controller)#, alert: "Hubo un error al desasignar el controlador."
    end
  end

  def edit
  end

  def update
    if @controller.update(controller_params)
      redirect_to controllers_path, notice: 'Controlador actualizado exitosamente.'
    else
      render :edit
    end
  end

  def destroy
    @controller.lockers.destroy_all
    @controller.destroy
    redirect_to controller_path, notice: 'Controlador eliminado exitosamente.'
  end

  private
  def set_controller
    @controller = Controller.find(params[:id])
  end

  def controller_params
    # params.permit(:name, :esp_32_mac_address)
    params.permit(:name, :esp32_mac_address, :locker_count)
    # params.require(:controller).permit(:name, :esp32_mac_address, :locker_count)
  end

  def authorize_user
    controller = Controller.find(params[:id])

    return if current_user.is_admin

    unless controller.user_id == current_user.id
      flash[:warning] = 'No tienes permiso para ver este Controlador.'
      redirect_to controllers_path#, alert: "No tienes permisos para ver este controlador."
    end
  end

  def configure_mqtt_topics
    controller_id = @controller.id

    # Publicación de las claves iniciales para cada locker
    @controller.lockers.each_with_index do |locker, index|
      password_topic = "controladores/#{controller_id}"
      MQTT_CLIENT.publish(password_topic, locker.password)
    end

    # Publicación del enlace del modelo actualizado
    model_url_topic = "controladores/#{controller_id}/model_url"
    model_url = @controller.model_url # Suponiendo que `model_url` está definido en el modelo Controller
    MQTT_CLIENT.publish(model_url_topic, model_url) if model_url.present?


    # Suscripción a los topics de estado para cada locker
    @controller.lockers.each do |locker|
      status_topic = "controladores/#{controller_id}/locker_#{locker.id}/status"
      MQTT_CLIENT.subscribe(status_topic)
    end
  end
end
