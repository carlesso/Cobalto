class ApplicationController < ActionController::Base
  protect_from_forgery
  rescue_from CanCan::AccessDenied do |e|
    flash[:error] = e.message
    redirect_to root_url
  end
end
