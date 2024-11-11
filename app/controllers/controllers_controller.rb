class ControllersController < ApplicationController
  
  before_action :authenticate_user!
  before_action :authorize_user, only: [:show]

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

end

