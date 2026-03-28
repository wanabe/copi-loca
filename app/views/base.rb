# frozen_string_literal: true
# rbs_inline: enabled

class Views::Base < Components::Base
  # @rbs @flash: Hash[Symbol, String]
  # @rbs @breadcrumbs: Array[Breadcrumb]

  # @rbs return: ActiveSupport::Cache::Store
  def cache_store = Rails.cache

  # @rbs flash: Hash[Symbol, String]
  # @rbs breadcrumbs: Array[Breadcrumb]
  # @rbs return: void
  def initialize(flash: {}, breadcrumbs: [])
    @flash = flash
    @breadcrumbs = breadcrumbs
  end

  # @rbs return: void
  def view_template
    render Components::Layout.new(flash: @flash, breadcrumbs: @breadcrumbs, view: self) do
      body_template
    end
  end

  # @rbs return: void
  def body_template
    raise NotImplementedError, "Subclasses must implement body_template"
  end
end
