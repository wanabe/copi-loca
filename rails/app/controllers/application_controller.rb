class ApplicationController < ActionController::Base
  before_action :add_home_breadcrumb
  helper_method :breadcrumbs

  def breadcrumbs
    @breadcrumbs ||= []
  end

  def add_breadcrumb(name, path = nil)
    breadcrumbs << Breadcrumb.new(name, path)
  end

  def add_home_breadcrumb
    add_breadcrumb("Home", root_path)
  end

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

    def add_action_breadcrumb
      add_breadcrumb(action_name)
    end
end
