class ModelsController < ApplicationController

  before_action :authenticate_user!
  
  # GET /models
  def index
    @models = Model.all
  end

  # GET /models/:id
  def show
    @model = Model.find(params[:id])
  end

  # POST /models/:id/update_user_model
  def update_user_model
    model = Model.find(params[:model_id])
    #esto (creo) q llama a update de user_controller, que a su vez llama a 
    #update_lockers_password_if_model_changed para cada controlador del usuario
    current_user.update(model: model)

    redirect_to model_path(model), notice: 'Tu Modelo ha sido actualizado!'
  end

end
