class ModelsController < ApplicationController

  before_action :authenticate_user!
  #before_action :check_admin, only: [:new, :create]

  # GET /models
  def index
    @models = Model.all
  end

  # GET /models/:id
  def show
    @model = Model.find(params[:id])
  end

  # GET /models/new
  def new
    @model = Model.new
    #6.times { @model.gestures.build }
    @model.gestures.build
  end

  # POST /models
  def create
    @model = Model.new(model_params)
    puts "Received params: #{params.inspect}" # Esto te muestra todos los parámetros recibidos en la consola.
  
    if @model.save
      redirect_to models_path, notice: 'Modelo creado exitosamente.'
    else
      puts "Model errors: #{@model.errors.full_messages}" # Depura los errores de validación
      render :new, status: :unprocessable_entity
    end
  end
  

  # POST /models/:id/update_user_model
  def update_user_model
    model = Model.find(params[:model_id])
    #esto (creo) q llama a update de user_controller, que a su vez llama a 
    #update_lockers_password_if_model_changed para cada controlador del usuario
    current_user.update(model: model)

    redirect_to model_path(model), notice: 'Tu Modelo ha sido actualizado!'
  end

  private

  def model_params
    params.require(:model).permit(
      :name, 
      :description, 
      :url,
      :version,
      gestures_attributes: [:id, :name, :description, :image, :_destroy])
  end

  #def check_admin
  #  unless current_user.is_admin?
  #    redirect_to models_path, alert: 'No tienes permiso para realizar esta acción.'
  #  end
  #end
end
