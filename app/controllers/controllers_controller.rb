class ControllersController < ApplicationController
  before_action :set_controller, only: %i[ show ]
  before_action :authenticate_user!
  before_action :authorize_user, only: [:show]
  after_action :configure_mqtt_topics, only: [:create]

  def new
    @controller = Controller.new # Esto inicializa un nuevo objeto Controller
  end

  def create
    Rails.logger.debug "Received parameters: #{params.inspect}"
    @controller = Controller.new(controller_params)
  
    # Crear lockers asociados con claves inicializadas a "0000"
    if @controller.save
      # Crear lockers con las claves inicializadas a "0000"
      @controller.lockers.each do |locker|
        locker.update(password: '0000') # Asignar la clave inicial de '0000' a cada locker
      end
  
      respond_to do |format|
        format.html { redirect_to controllers_path, notice: "Controlador creado exitosamente." }
        format.json { render json: @controller, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new }
        format.json { render json: @controller.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /controllers
  def index
    @controllers = Controller.where(user_id: current_user.id)
  end

  # GET /controllers/available
  def available
    @controllers = Controller.where(user_id: nil)
  end

  # GET /controllers/:id
  def show
    @controller = Controller.find(params[:id])
    @model = @controller.user.model
    @lockers = @controller.lockers
    @connected = @controller.last_seen_at && (Time.current - @controller.last_seen_at) <= 10.minutes
  end

  # PATCH /controllers/:id/assign_to_user
  def assign_to_user
    @controller = Controller.find(params[:id])

    puts @controller.inspect

    if @controller.update!(user_id: current_user.id)
      #regenerate_lockers_passwords tiene dentro suyo la publicacion de las 
      #nuevas claves, junto con model_url (aunque no haya cambiado), a mqtt
      @controller.regenerate_lockers_passwords_if_model_changed
      redirect_to controllers_path, notice: "Controlador asignado correctamente."
    else
      render :available_path, alert: "Hubo un error al asignar el controlador."
    end
  end

  # PATCH /controllers/:id/unlink_from_user
  def unlink_from_user
    @controller = Controller.find(params[:id])

    if @controller.update!(user_id: nil)
      redirect_to controllers_path, notice: "Controlador desasignado correctamente."
    else
      redirect_to show_controller_path(@controller), alert: "Hubo un error al desasignar el controlador."
    end
  end

  # para mandar los passwords actualizados a mqtt
  # aunque la vd es que no sabria como llamarlo en particular..
  #def update_passwords
  #  @controller = Controller.find(params[:id])

  #  if @controller.update(controller_locker_params)
  #    @controller.publish_lockers_passwords
  #    redirect_to controller_path(@controller), notice: 'Lockers Passwords updated'
  #  else
  #    Rails.logger.error(@controller.errors.full_messages)
  #    redirect_to controller_path(@controller), alert: 'Error updating Lockers Passwords'
  #  end
  #end

  private 

  def set_controller
    @controller = Controller.find(params[:id])
  end

  def controller_params
    # params[:controller]
    # permit(:name, :esp32_mac_address, :locker_count)
    params.require(:controller).permit(:name, :esp32_mac_address, :locker_count)
  end

  def controller_locker_params
    params.require(:controller).permit(
      :name,
      lockers_attributes: [:id, :name]
    )
  end

  def authorize_user
    controller = Controller.find(params[:id])
    unless controller.user_id == current_user.id
      redirect_to controllers_path, alert: "No tienes permisos para ver este controlador."
    end
  end

  def configure_mqtt_topics
    controller_id = @controller.id

    # Publicación de las claves iniciales para cada locker
    @controller.lockers.each_with_index do |locker, index|
      password_topic = "controladores/#{controller_id}/locker_#{locker.id}/clave"
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

