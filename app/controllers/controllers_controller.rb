class ControllersController < ApplicationController
  
  
  def index
    @controllers = Controller.all
  end

  def update_passwords
    controller = Controller.find(params[:id])

  end

  private 

  def controller_params
    params.require(:controller).permit(
      :name, 
      :esp32_mac_address, 
      :last_seen_at, 
      :locker_count, 
      :user_id
    )
  end

end

