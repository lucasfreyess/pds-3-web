class ControllersController < ApplicationController
  
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
    @controller = Controller.find(params[:id])
    if @controller.user
      @model = @controller.user.model
    else
      @model = nil
    end

    @lockers = @controller.lockers.order(:id)
    @connected = @controller.last_seen_at && (Time.current - @controller.last_seen_at) <= 10.minutes
    
    # si no se hace flash.now entonces el mensaje se muestra en la siguiente vista xd
    if @connected
      flash.now[:info] = "¡Conexión exitosa!"
    else
      flash.now[:warning] = "No se pudo conectar al controlador."
    end
  end

  # GET /controllers/new
  def new
    @controller = Controller.new
    @controller.lockers.build
  end

  # POST /controllers
  def create
    @controller = Controller.new(controller_locker_params)

    if @controller.save
      flash[:success] = "Controlador creado correctamente."
      redirect_to controllers_path#, notice: "Controlador creado correctamente."
    else
      flash[:danger] = "Hubo un error al crear el controlador."
      render :new#, alert: "Hubo un error al crear el controlador."
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

  def controller_locker_params
    params.require(:controller).permit(
      :name,
      :esp_32_mac_address,
      lockers_attributes: [:id, :name]
    )
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

