class HomeController < ApplicationController
  
  before_action :authenticate_user!

  # dashboard
  def index
  end
end
