class LockersController < ApplicationController
  
  before_action :authenticate_user!
  before_action :authorize_user, only: [:edit]

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
    MQTT_CLIENT.publish(topic_base, new_password)

    if @locker.update!(
      name: params[:locker][:name],
      owner_email: params[:locker][:owner_email],
      password: new_password
      )
        redirect_to show_controller_path(@locker.controller), notice: 'Locker se actualizo!!'
    else
        render :edit
    end
  end

  private

  def locker_params
    params.require(:locker).permit(:name, :owner_email)
  end

  def authorize_user
    locker = Locker.find(params[:id])
    controller = locker.controller
    unless controller.user_id == current_user.id
      redirect_to controllers_path, alert: "No tienes permisos para ver este casillero."
    end
  end
  
end
