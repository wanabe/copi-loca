class OperationsController < ApplicationController
  before_action :set_operation, only: %i[ show edit update destroy run ]

  # GET /operations
  def index
    @operations = Operation.all
  end

  # GET /operations/1
  def show
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
    @output, @status = @operation.run
    render partial: "run"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_operation
      @operation = Operation.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def operation_params
      params.expect(operation: [ :command, :directory ])
    end
end
