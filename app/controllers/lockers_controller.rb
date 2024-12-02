class LockersController < ApplicationController
  
  before_action :authenticate_user!
  before_action :authorize_user, only: [:show, :edit]

  # GET /lockers/:id
  def show
    @locker = Locker.find(params[:id])
    @controller = @locker.controller
  end

  # GET /lockers/:id/edit
  def edit
    @locker = Locker.find(params[:id])
  end

  # PATCH /lockers/:id
  def update
    @locker = Locker.find(params[:id])

    new_password = [
      params[:locker][:password_0],
      params[:locker][:password_1],
      params[:locker][:password_2],
      params[:locker][:password_3]
    ]

    # aqui hay que mandar el nuevo password al mqtt!!
    
    topic_base = "controladores/#{@locker.controller.id}/locker_#{@locker.id}/clave"
    #MQTT_CLIENT.publish(topic_base, new_password)

    if @locker.update!(
      owner_email: params[:locker][:owner_email],
      password: new_password
      )
        flash[:success] = 'Casillero se actualizo exitosamente.'
        redirect_to controller_path(@locker.controller)#, notice: 'Locker se actualizo!!'
    else
        flash[:danger] = 'Error al actualizar el Casillero.'
        render :edit
    end
  end

  private

  def locker_params
    params.require(:locker).permit(:owner_email)
  end

  def authorize_user
    locker = Locker.find(params[:id])
    controller = locker.controller

    return if current_user.is_admin

    unless controller.user_id == current_user.id
      flash[:warning] = 'No tienes permiso para editar este Casillero.'
      redirect_to controllers_path#, alert: "No tienes permisos para ver este casillero."
    end
  end
  
end
