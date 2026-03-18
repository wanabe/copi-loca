# frozen_string_literal: true

class MemosController < ApplicationController
  before_action :add_memos_breadcrumb

  # GET /memos
  def index
    render Views::Memos::Index.new
  end

  private

  def add_memos_breadcrumb
    add_breadcrumb("Memos", memos_path)
  end
end
