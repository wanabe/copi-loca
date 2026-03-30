# frozen_string_literal: true
# rbs_inline: enabled

class ApplicationController < ActionController::Base
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

  layout false

  class << self
    # @rbs *base_names: Symbol
    # @rbs return: void
    def parameters(*base_names)
      namespace = "Parameters::#{name.sub('Controller', '')}"
      base_names.each do |base_name|
        parameter_class = "#{namespace}::#{base_name.to_s.camelize}"
        parameter_name = "#{base_name}_parameters"
        class_eval(<<~RUBY, __FILE__, __LINE__ + 1)
          private def #{parameter_name}                            # private def index_parameters
            @#{parameter_name} ||= #{parameter_class}.from(params) #   @index_parameters ||= Parameters::Git::Commits::Index.from(params)
          end                                                      # end
        RUBY
      end
    end
  end

  module Breadcrumbs
    # @rbs!
    #  def action_name: () -> String
    #  def root_path: () -> String

    # @rbs @breadcrumbs: Array[Breadcrumb]

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
    def add_action_breadcrumb
      add_breadcrumb(action_name)
    end

    # @rbs return: void
    def add_home_breadcrumb
      add_breadcrumb("Home", root_path)
    end
  end
  include Breadcrumbs
end
