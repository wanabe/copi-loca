# frozen_string_literal: true

class ToolsController < ApplicationController
  before_action :set_tool, only: %i[show edit update destroy]
  before_action :add_collection_breadcrumb
  before_action :add_member_breadcrumb, only: %i[show edit]
  before_action :add_action_breadcrumb, only: %i[new edit]

  # GET /tools
  def index
    @tools = Tool.all

    render Views::Tools::Index.new(tools: @tools)
  end

  # GET /tools/1
  def show
    render Views::Tools::Show.new(tool: @tool)
  end

  # GET /tools/new
  def new
    @tool = Tool.new

    render Views::Tools::New.new(tool: @tool)
  end

  # GET /tools/1/edit
  def edit
    render Views::Tools::Edit.new(tool: @tool)
  end

  # POST /tools
  def create
    @tool = Tool.new(tool_params)

    if @tool.save
      redirect_to @tool, notice: "Tool was successfully created."
    else
      render Views::Tools::New.new(tool: @tool), status: :unprocessable_content
    end
  end

  # PATCH/PUT /tools/1
  def update
    if @tool.update(tool_params)
      redirect_to @tool, notice: "Tool was successfully updated.", status: :see_other
    else
      render Views::Tools::Edit.new(tool: @tool), status: :unprocessable_content
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
    params.expect(tool: [:name, :description, :script,
                         { tool_parameters_attributes: %i[id name description _destroy] }])
  end

  def add_collection_breadcrumb
    add_breadcrumb("Tools", tools_path)
  end

  def add_member_breadcrumb
    add_breadcrumb(@tool.id, tool_path(@tool))
  end
end
