class HomeController < ApplicationController
  
  before_action :authenticate_user!

  # dashboard
  def index
    if current_user.is_admin
      @active_controllers_count = current_user.active_controllers
      @active_lockers_count = current_user.active_lockers
      @active_users_count = current_user.active_users

      @locker_openings_by_day = current_user.locker_openings_last_7_days
      puts "LOCKER OPENINGS BY DAY #{@locker_openings_by_day}"

      @most_used_model = current_user.most_used_model_last_7_days
      
      @unique_users_changed_model = current_user.unique_users_changed_model_last_7_days
      puts "UNIQUE USERS CHANGED MODEL #{@unique_users_changed_model}"

      @average_opening_time_by_model_last_7_days = current_user.average_opening_time_by_model_last_7_days
      puts "AVERAGE OPENING TIME BY MODEL #{@average_opening_time_by_model_last_7_days}"
      
      @models_with_most_failed_openings_last_7_days = current_user.models_with_most_failed_openings_last_7_days
      puts "MODELS WITH MOST FAILED OPENINGS #{@models_with_most_failed_openings_last_7_days}"

    else
      @locker_openings_by_day = current_user.locker_openings_last_7_days
      puts "LOCKER OPENINGS BY DAY #{@locker_openings_by_day}"
      
      @most_opened_locker = current_user.most_opened_locker_last_7_days
      @unique_owners_opened = current_user.unique_owners_opened_last_7_days
      @average_opening_time_last_7_days = current_user.average_opening_time_last_7_days
      puts "AVERAGE OPENING TIME #{@average_opening_time_last_7_days}"
    end
  end
end