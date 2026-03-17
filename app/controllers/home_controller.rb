# frozen_string_literal: true

class HomeController < ApplicationController
  # GET /
  def index
    render Views::Home::Index.new
  end
end
