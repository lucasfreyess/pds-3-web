class ControladorrsController < ApplicationController
  before_action :set_controladorr, only: %i[ show edit update destroy ]

  # GET /controladorrs or /controladorrs.json
  def index
    @controladorrs = Controladorr.all
  end

  # GET /controladorrs/1 or /controladorrs/1.json
  def show
  end

  # GET /controladorrs/new
  def new
    @controladorr = Controladorr.new
  end

  # GET /controladorrs/1/edit
  def edit
  end

  # POST /controladorrs or /controladorrs.json
  def create
    Rails.logger.debug "Received parameters: #{params.inspect}"
    @controller = Controller.new(controller_params)
  
    # Crear lockers asociados con claves inicializadas a "0000"
    if @controller.save
      # Crear lockers con las claves inicializadas a "0000"
      @controller.lockers.each do |locker|
        locker.update(password: '0000') # Asignar la clave inicial de '0000' a cada locker
      end
  
      respond_to do |format|
        format.html { redirect_to controllers_path, notice: "Controlador creado exitosamente." }
        format.json { render json: @controller, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new }
        format.json { render json: @controller.errors, status: :unprocessable_entity }
      end
    end
  end
  

  # PATCH/PUT /controladorrs/1 or /controladorrs/1.json
  def update
    respond_to do |format|
      if @controladorr.update(controladorr_params)
        format.html { redirect_to @controladorr, notice: "Controladorr was successfully updated." }
        format.json { render :show, status: :ok, location: @controladorr }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @controladorr.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /controladorrs/1 or /controladorrs/1.json
  def destroy
    @controladorr.destroy!

    respond_to do |format|
      format.html { redirect_to controladorrs_path, status: :see_other, notice: "Controladorr was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_controladorr
      @controladorr = Controladorr.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def controladorr_params
      params.require(:controladorr).permit(:name, :esp32_mac_address, :locker_count)
    end
end
