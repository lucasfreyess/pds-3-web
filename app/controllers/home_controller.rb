class HomeController < ApplicationController
  
  before_action :authenticate_user!

  # dashboard
  def index
    if current_user.is_admin
      # active_lockers se deriva de los controladores activos
      @active_controllers_count = current_user.active_controllers
      @active_lockers_count = current_user.active_lockers
      @active_users_count = current_user.active_users
      @locker_openings_by_day = current_user.locker_openings_last_7_days
      @most_used_model = current_user.most_used_model_last_7_days
      @unique_users_changed_model = current_user.unique_users_changed_model_last_7_days
      puts "LOCKER OPENINGS BY DAY #{@locker_openings_by_day}"
    else
      @locker_openings_by_day = current_user.locker_openings_last_7_days
      @most_opened_locker = current_user.most_opened_locker_last_7_days
      @unique_owners_opened = current_user.unique_owners_opened_last_7_days
      puts "LOCKER OPENINGS BY DAY #{@locker_openings_by_day}"
    end
  end
end