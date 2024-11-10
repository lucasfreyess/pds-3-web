class ControllersController < ApplicationController
  
  before_action :authenticate_user!

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
    @lockers = @controller.lockers
    @connected = @controller.last_seen_at && (Time.current - @controller.last_seen_at) <= 10.minutes
  end

  # POST /controllers/:id/assign_to_user
  def assign_to_user
    @controller = Controller.find(params[:id])

    puts @controller.inspect

    if @controller.update!(user_id: current_user.id)
      redirect_to controllers_path, notice: "Controlador asignado correctamente."
    else
      render :available_path, alert: "Hubo un error al asignar el controlador."
    end
  end

  def unlink_from_user
    @controller = Controller.find(params[:id])

    if @controller.update!(user_id: nil)
      redirect_to controllers_path, notice: "Controlador desasignado correctamente."
    else
      redirect_to controller_path(controller), alert: "Hubo un error al desasignar el controlador."
    end
  end

  # para mandar los passwords actualizados a mqtt
  # aunque la vd es que no sabria como llamarlo en particular..
  # para ello tengo q hacer las vistas primero!
  def update_passwords
    @controller = Controller.find(params[:id])

    if @controller.update(controller_locker_params)
      @controller.publish_lockers_passwords
      redirect_to @controller, notice: 'Lockers Passwords updated'
    else
      Rails.logger.error(@controller.errors.full_messages)
      redirect_to @controller, alert: 'Error updating Lockers Passwords'
    end

  end

  private 

  def controller_aaaparams
    params.require(:controller).permit(
      :name, 
      :esp32_mac_address, 
      :last_seen_at, 
      :locker_count, 
      :user_id
    )
  end

  def controller_locker_params
    params.require(:controller).permit(
      lockers_attributes: [:password]
    )
  end

  def controller_params
    params.require(:controller).permit(
      :name,
      lockers_attributes: [:id, :name]
    )
  end

end

