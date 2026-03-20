# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :add_home_breadcrumb

  layout -> { request.format.html? ? Views::Layouts::Application.new(breadcrumbs: breadcrumbs) : nil }

  private

  def breadcrumbs
    @breadcrumbs ||= []
  end

  def add_breadcrumb(name, path = nil)
    breadcrumbs << Breadcrumb.new(name, path)
  end

  def add_home_breadcrumb
    add_breadcrumb("Home", root_path)
  end

  def add_git_breadcrumb
    add_breadcrumb("Git", git_root_path)
  end

  def add_action_breadcrumb
    add_breadcrumb(action_name)
  end
end
