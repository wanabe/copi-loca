class ToolsController < ApplicationController
  before_action :set_tool, only: %i[ show edit update destroy ]

  # GET /tools
  def index
    @tools = Tool.all
  end

  # GET /tools/1
  def show
  end

  # GET /tools/new
  def new
    @tool = Tool.new
  end

  # GET /tools/1/edit
  def edit
  end

  # POST /tools
  def create
    @tool = Tool.new(tool_params)

    if @tool.save
      redirect_to @tool, notice: "Tool was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  # PATCH/PUT /tools/1
  def update
    if @tool.update(tool_params)
      redirect_to @tool, notice: "Tool was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /tools/1
  def destroy
    @tool.destroy!
    redirect_to tools_path, notice: "Tool was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tool
      @tool = Tool.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def tool_params
      params.expect(tool: [ :description, :script ])
    end
end
