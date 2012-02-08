class ApplicationController < ActionController::Base
  protect_from_forgery

  def logged_in?
    user_logged_in?
  end
end
