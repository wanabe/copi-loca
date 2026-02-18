class OperationsController < ApplicationController
  before_action :set_operation, only: %i[ show edit update destroy run ]
  before_action :add_collection_breadcrumb
  before_action :add_member_breadcrumb, only: %i[ show edit ]
  before_action :add_action_breadcrumb, only: %i[ new edit ]

  # GET /operations
  def index
    @operations = Operation.all
  end

  # GET /operations/1
  def show
    if @operation.immediate?
      @output, @status = @operation.run
    end
  end

  # GET /operations/new
  def new
    @operation = Operation.new
  end

  # GET /operations/1/edit
  def edit
  end

  # POST /operations
  def create
    @operation = Operation.new(operation_params)

    if @operation.save
      redirect_to @operation, notice: "Operation was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  # PATCH/PUT /operations/1
  def update
    if @operation.update(operation_params)
      redirect_to @operation, notice: "Operation was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /operations/1
  def destroy
    @operation.destroy!
    redirect_to operations_path, notice: "Operation was successfully destroyed.", status: :see_other
  end

  def run
    if @operation.background?
      RunOperationJob.perform_later(@operation.id)
    else
      @output, @status = @operation.run
    end
    render partial: "run", locals: { operation: @operation, output: @output, status: @status }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_operation
      @operation = Operation.find(params[:id])
    end

    def add_collection_breadcrumb
      add_breadcrumb("Operations", operations_path)
    end

    def add_member_breadcrumb
      add_breadcrumb(@operation.id, operation_path(@operation))
    end

    def add_action_breadcrumb
      add_breadcrumb(action_name)
    end

    # Only allow a list of trusted parameters through.
    def operation_params
      params.require(:operation).permit(:command, :directory, :execution_timing)
    end
end
