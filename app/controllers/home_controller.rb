class HomeController < ApplicationController
  
  before_action :authenticate_user!

  # dashboard
  def index
    if current_user.is_admin
      @controllers = Controller.all
    else
      @locker_openings_by_day = current_user.locker_openings_last_7_days
      @most_opened_locker = current_user.most_opened_locker_last_7_days
      @unique_owners_opened = current_user.unique_owners_opened_last_7_days
    end
  end
end