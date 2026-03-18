# frozen_string_literal: true

class MemosController < ApplicationController
  before_action :add_memos_breadcrumb

  # GET /memos
  def index
    render Views::Memos::Index.new
  end

  # POST /memos/sync_local_memos
  # Receives local memos as JSON and saves to docs/memos.json
  def sync_local_memos
    begin
      memos = JSON.parse(request.body.read)
      File.open(Rails.root.join('docs', 'memos.json'), 'w') do |f|
        f.write(JSON.pretty_generate(memos))
      end
      render json: { status: 'success' }, status: :ok
    rescue => e
      render json: { status: 'error', message: e.message }, status: :unprocessable_entity
    end
  end

  private

  def add_memos_breadcrumb
    add_breadcrumb("Memos", memos_path)
  end
end
