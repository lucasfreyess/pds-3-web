class ModelsController < ApplicationController

  before_action :authenticate_user!
  before_action :check_admin, only: [:new, :create, :edit, :update, :destroy]

  # GET /models/:id/json
  def json
    model = Model.find(params[:id])
    #render json: model.to_json(include: :gestures, except: [:created_at, :updated_at])

    render json: {
      model: model.as_json(include: {
        gestures: {
          except: [:created_at, :updated_at, :model_id]
        }
        #model_file: model.model_file.attached? ? Base64.encode64(model.model_file.download) : nil
        # lo siguiente hacia papugpt en el modelo del model xd
        # file: model_file&.download&.force_encoding('UTF-8') # Contenido del archivo subido
      },
      except: [:created_at, :updated_at]
      ).merge(
        file: model.model_file.attached? ? model.model_file&.download&.force_encoding('UTF-8') : nil# Contenido del archivo subido
      )
    },
    status: :ok

  end

  # GET /models
  def index
    if current_user.is_admin
      @models = Model.all
    else
      # magia de sql para obtener primero el modelo del usuario!!
      @models = Model.all
      @models = @models.sort_by { |model| model.id == current_user.model_id ? 0 : 1 }.reverse
    end
  end

  # GET /models/:id
  def show
    @model = Model.find(params[:id])
  end

  # GET /models/new
  def new
    @model = Model.new
    6.times { @model.gestures.build } #por el mínimo de gestos!!
    #@model.gestures.build
  end

  # POST /models
  def create
    @model = Model.new(model_params)
    puts "Received params: #{params.inspect}" # Esto te muestra todos los parámetros recibidos en la consola.

    if @model.save
      @model.set_url(request.host_with_port)
      flash[:success] = 'Modelo creado exitosamente.'
      redirect_to models_path#, notice: 'Modelo creado exitosamente.'
    else
      puts "Model errors: #{@model.errors.full_messages}" # Depura los errores de validación
      flash[:danger] = 'Error al crear el Modelo.'
      render :new, status: :unprocessable_entity
    end
  end

  #GET /models/:id/edit
  def edit
    @model = Model.find(params[:id])
  end

  # PATCH /models/:id
  def update
    @model = Model.find(params[:id])
    if @model.update(model_params)
      @model.set_url(request.host_with_port)
      flash[:success] = 'Modelo actualizado exitosamente.'
      redirect_to models_path#, notice: 'Modelo actualizado exitosamente.'
    else
      flash[:danger] = 'Error al actualizar el Modelo.'
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /models/:id
  def destroy
    model = Model.find(params[:id])

    if model.destroy!
      flash[:success] = 'Modelo eliminado exitosamente.'
      redirect_to models_path#, notice: 'Modelo eliminado exitosamente.'
    else
      flash[:danger] = 'Error al eliminar el Modelo; Existen usuarios asociados.'
      redirect_to model_path(model)#, alert: 'Error al eliminar el Modelo.'
    end
  end

  # POST /models/:id/update_user_model
  def update_user_model
    model = Model.find(params[:model_id])
    #esto (creo) q llama a update de user_controller, que a su vez llama a
    #update_lockers_password_if_model_changed para cada controlador del usuario
    current_user.update(model: model)

    flash[:success] = 'Tu Modelo ha sido actualizado exitosamente.'
    redirect_to model_path(model)#, notice: 'Tu Modelo ha sido actualizado!'
  end

  private

  def model_params
    params.require(:model).permit(
      :name,
      :description,
      #:url,
      :version,
      :model_file,
      gestures_attributes: [:id, :name, :description, :image, :_destroy])
  end

  def check_admin
    unless current_user.is_admin?
      flash[:warning] = 'No tienes permiso para realizar esta acción.'
      redirect_to models_path#, alert: 'No tienes permiso para realizar esta acción.'
    end
  end
end
