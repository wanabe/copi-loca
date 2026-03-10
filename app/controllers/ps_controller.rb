# frozen_string_literal: true

class PsController < ApplicationController
  # GET /ps
  def index
    @lines = `ps -ef`.split("\n")
    render Views::Ps::Index.new(lines: @lines)
  end
end
