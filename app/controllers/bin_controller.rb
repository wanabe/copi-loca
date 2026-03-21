# frozen_string_literal: true
# rbs_inline: enabled

class BinController < ApplicationController
  # @rbs @bin: Bin

  before_action :add_bins_breadcrumb
  before_action :add_bin_breadcrumb, only: %i[show run]
  before_action :add_action_breadcrumb, only: %i[run]

  # GET /bin or /bin.json
  # @rbs return: void
  def index
    bins = Kaminari.paginate_array(Bin.all).page(params[:page]).per(params[:per_page] || 5)
    render Views::Bin::Index.new(bins: bins, notice: flash[:notice])
  end

  # GET /bin/:id or /bin/:id.json
  # @rbs return: void
  def show
    render Views::Bin::Show.new(bin: bin, notice: flash[:notice])
  end

  # POST /bin/:id/run or /bin/:id/run.json
  # @rbs return: void
  def run
    status, output = bin.run
    render Components::Bin::Run.new(status: status, output: output), layout: false
  end

  private

  # @rbs return: Bin
  def bin
    @bin ||= Bin.find(params.expect(:id))
  end

  # @rbs return: void
  def add_bins_breadcrumb
    add_breadcrumb("Bins", bin_index_path)
  end

  # @rbs return: void
  def add_bin_breadcrumb
    add_breadcrumb(bin.id.to_s, bin_path(bin))
  end
end
