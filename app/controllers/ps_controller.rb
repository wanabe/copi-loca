# frozen_string_literal: true
# rbs_inline: enabled

class PsController < ApplicationController
  before_action :add_ps_breadcrumb

  # GET /ps
  # @rbs return: void
  def index
    # @rbs @lines: Array[String]

    @lines = `ps -ef`.split("\n")
    render Views::Ps::Index.new(breadcrumbs: breadcrumbs, flash: flash, lines: @lines)
  end

  private

  # def add_ps_breadcrumb: () -> void
  # @rbs return: void
  def add_ps_breadcrumb
    add_breadcrumb("Ps", ps_path)
  end
end
