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
    current_user.update(model: model)

    # se deberia enviar el url del nuevo modelo a un topic mqtt aca

    redirect_to model_path(model), notice: 'Tu Modelo ha sido actualizado!'
  end

end
