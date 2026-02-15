class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  before_action :authenticate
  skip_before_action :authenticate, if: -> { request.format.turbo_stream? }

  private
  def authenticate
    return if ENV["COPI_ADMIN_PASSWORD"].blank?
    return if session[:admin]
    redirect_to new_auth_session_path, alert: "Please log in."
  end
end
