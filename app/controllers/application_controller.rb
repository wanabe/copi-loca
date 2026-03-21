# frozen_string_literal: true
# rbs_inline: enabled

class ApplicationController < ActionController::Base
  # @rbs @breadcrumbs: Array[Breadcrumb]

  # Dummy
  # @rbs!
  #   def self.stale_when_importmap_changes: () -> void
  #   def self.phlex_layout: () -> nil
  #   def render: (?(Phlex::HTML | Symbol), **untyped) -> void

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :add_home_breadcrumb

  layout -> { phlex_layout }

  private

  # @rbs return: Phlex::HTML | nil
  def phlex_layout
    request.format.html? ? Views::Layouts::Application.new(breadcrumbs: breadcrumbs) : nil
  end

  # @rbs return: Array[Breadcrumb]
  def breadcrumbs
    @breadcrumbs ||= []
  end

  # @rbs name: String
  # @rbs path: String?
  # @rbs return: void
  def add_breadcrumb(name, path = nil)
    breadcrumbs << Breadcrumb.new(name, path)
  end

  # @rbs return: void
  def add_home_breadcrumb
    add_breadcrumb("Home", root_path)
  end

  # @rbs return: void
  def add_git_breadcrumb
    add_breadcrumb("Git", git_root_path)
  end

  # @rbs return: void
  def add_action_breadcrumb
    add_breadcrumb(action_name)
  end
end
