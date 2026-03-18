# frozen_string_literal: true

class BinController < ApplicationController
  before_action :set_bin, only: %i[show run]
  before_action :add_bins_breadcrumb
  before_action :add_bin_breadcrumb, only: %i[show run]
  before_action :add_action_breadcrumb, only: %i[run]

  # GET /bin or /bin.json
  def index
    @bins = Kaminari.paginate_array(Bin.all).page(params[:page]).per(params[:per_page] || 5)
    render Views::Bin::Index.new(bins: @bins, notice: flash[:notice])
  end

  # GET /bin/:id or /bin/:id.json
  def show
    render Views::Bin::Show.new(bin: @bin, notice: flash[:notice])
  end

  def run
    @status, @output = @bin.run
    respond_to do |format|
      format.html { render Components::Bin::Run.new(status: @status, output: @output), layout: false }
      format.json { render :show, status: :ok, location: @bin }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_bin
    @bin = Bin.find(params.expect(:id))
  end

  def add_bins_breadcrumb
    add_breadcrumb("Bins", bin_index_path)
  end

  def add_bin_breadcrumb
    add_breadcrumb(@bin.id, bin_path(@bin))
  end
end
