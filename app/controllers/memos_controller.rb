# frozen_string_literal: true

class MemosController < ApplicationController
  # GET /memos
  def index
    render Views::Memos::Index.new
  end
end
