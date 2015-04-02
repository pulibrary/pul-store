class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  # Please be sure to impelement current_user and user_session. Blacklight depends on
  # these methods in order to perform user specific actions.
  #before_filter :authenticate_user!
  layout 'blacklight'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  protect_from_forgery with: :exception

  # force CAS on all pages
  #before_action :redirect_to_sign_in, unless: :user_signed_in?

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to '/users/sign_in', :alert => exception.message
  end

  def current_or_guest_user
    if current_user
      if session[:guest_user_id]
        logging_in
        guest_user.destroy
        session[:guest_user_id] = nil
      end
      current_user
    else
      guest_user
    end
  end

  def after_sign_in_path_for(resource)
    session[:path_to_redirect_to] || stored_location_for(resource) || root_path
  end

  private
  def redirect_to_sign_in
    logger.debug "you are being redirected"
    unless session[:path_to_redirect_to].blank?
      session[:path_to_redirect_to] = request.original_fullpath
    end
    redirect_to new_user_session_path
  end

end
