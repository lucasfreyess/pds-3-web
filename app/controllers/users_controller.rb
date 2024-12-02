class UsersController < ApplicationController
  
  before_action :authenticate_user!
  before_action :check_admin, only: [:index, :show, :destroy]

  # GET /users
  def index
    @users = User.where(is_admin: false)
  end

  # GET /users/:id
  def show
    @user = User.find(params[:id])
    @model = @user.model
    @controllers = @user.controllers
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      # el callback update_lockers_password_if_model_changed
      # en el modelo user.rb se encarga de regenerar las contraseñas
      flash[:success] = 'Modelo actualizado y contraseñas regeneradas.'
      redirect_to @user#, notice: 'Modelo actualizado y contraseñas regeneradas.'
    else
      
    end
  end

  # DELETE /users/:id
  def destroy
    @user = User.find(params[:id])
    @controllers = @user.controllers

    if @controllers.any?
      @controllers.each do |controller|
        controller.update!(user_id: nil)
      end
    end

    if @user.is_admin
      flash[:warning] = 'No puedes eliminar a un administrador.'
      redirect_to users_path
    else
      @user.destroy
      flash[:success] = 'Usuario eliminado exitosamente.'
      redirect_to users_path
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

  def check_admin
    unless current_user.is_admin?
      flash[:warning] = 'No tienes permiso para realizar esta acción.'
      redirect_to models_path#, alert: 'No tienes permiso para realizar esta acción.'
    end
  end
end
