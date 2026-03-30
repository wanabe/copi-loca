# frozen_string_literal: true
# rbs_inline: enabled

class MemosController < ApplicationController
  # @rbs @sync_local_memos_parameters: Parameters::Memos::SyncLocalMemos?

  # @rbs!
  #   def sync_local_memos_parameters: () -> Parameters::Memos::SyncLocalMemos?

  parameters :sync_local_memos

  before_action :add_memos_breadcrumb

  # GET /memos
  # @rbs return: void
  def index
    render Views::Memos::Index.new(breadcrumbs: breadcrumbs, flash: flash)
  end

  # POST /memos/sync_local_memos
  # Receives local memos as JSON and saves to docs/memos.json
  # @rbs return: void
  def sync_local_memos
    Rails.root.join("docs/memos.json").write(JSON.pretty_generate(sync_local_memos_parameters.as_json))
    render json: { status: "success" }, status: :ok
  rescue StandardError => e
    render json: { status: "error", message: e.message }, status: :unprocessable_content
  end

  private

  # def add_memos_breadcrumb: () -> void
  # @rbs return: void
  def add_memos_breadcrumb
    add_breadcrumb("Memos", memos_path)
  end
end
