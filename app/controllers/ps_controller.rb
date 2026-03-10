# frozen_string_literal: true

class PsController < ApplicationController
  # GET /ps
  def index
    @ps = `ps -ef`.split("\n")
    render Views::Ps::Index.new(ps: @ps)
  end
end
