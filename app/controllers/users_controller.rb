class UsersController < ApplicationController
  
  before_action :authenticate_user!
  #before_action :is_not_admin

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      # el callback update_lockers_password_if_model_changed
      # en el modelo user.rb se encarga de regenerar las contraseñas
      redirect_to @user, notice: 'Modelo actualizado y contraseñas regeneradas.'
    else
      #render :edit #ermm hay q ver esto segun como se modifique en la vista.
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :name, 
      :email, 
      :model_id, 
      :is_admin
    ) # probablemente is_admin no vaya
  end
end
