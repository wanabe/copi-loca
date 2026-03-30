# frozen_string_literal: true
# rbs_inline: enabled

class BinController < ApplicationController
  # @rbs @bin: Bin
  # @rbs @index_parameters: Parameters::Bin::Index?
  # @rbs @show_parameters: Parameters::Bin::Show?
  # @rbs @run_parameters: Parameters::Bin::Run?

  # @rbs!
  #   def index_parameters: () -> Parameters::Bin::Index?
  #   def show_parameters: () -> Parameters::Bin::Show?
  #   def run_parameters: () -> Parameters::Bin::Run?

  parameters :index, :show, :run

  before_action :add_bins_breadcrumb
  before_action :add_bin_breadcrumb, only: %i[show run]
  before_action :add_action_breadcrumb, only: %i[run]

  # GET /bin or /bin.json
  # @rbs return: void
  def index
    parameters = index_parameters || raise(ArgumentError, "Invalid parameters")
    bins = Kaminari.paginate_array(Bin.all).page(parameters.page).per(parameters.per_page)
    render Views::Bin::Index.new(breadcrumbs: breadcrumbs, flash: flash, bins: bins)
  end

  # GET /bin/:id or /bin/:id.json
  # @rbs return: void
  def show
    render Views::Bin::Show.new(breadcrumbs: breadcrumbs, flash: flash, bin: bin)
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
    return @bin if @bin

    member_parameters = show_parameters || run_parameters
    raise(ArgumentError, "Invalid parameters") unless member_parameters

    @bin = Bin.find(member_parameters.id)
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
