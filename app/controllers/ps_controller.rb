# frozen_string_literal: true

class PsController < ApplicationController
  before_action :add_ps_breadcrumb

  # GET /ps
  def index
    @lines = `ps -ef`.split("\n")
    render Views::Ps::Index.new(lines: @lines)
  end

  private

  def add_ps_breadcrumb
    add_breadcrumb("Ps", ps_path)
  end
end
