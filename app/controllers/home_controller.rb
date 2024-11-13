class HomeController < ApplicationController
  
  before_action :authenticate_user!

  # dashboard
  def index
    @locker_openings_by_day = current_user.locker_openings_last_7_days
    @most_opened_locker = current_user.most_opened_locker_last_7_days
  end
end