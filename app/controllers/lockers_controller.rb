class LockersController < ApplicationController
  
  before_action :authenticate_user!

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
    
    if @locker.update!(
      name: params[:locker][:name],
      owner_email: params[:locker][:owner_email],
      password: new_password
      )
        redirect_to controller_path(@locker.controller), notice: 'Locker se actualizo!!'
    else
        render :edit
    end
  end

  private

  def locker_params
    params.require(:locker).permit(:name, :owner_email)
  end
  
end
