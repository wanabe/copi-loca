class CustomAgentsController < ApplicationController
  before_action :set_custom_agent, only: %i[ show edit update destroy ]

  before_action :add_custom_agents_breadcrumb
  before_action :add_custom_agent_breadcrumb, only: %i[ show edit ]
  before_action :add_action_breadcrumb, only: %i[ edit new ]

  # GET /custom_agents
  def index
    @custom_agents = CustomAgent.all
  end

  # GET /custom_agents/1
  def show
  end

  # GET /custom_agents/new
  def new
    @custom_agent = CustomAgent.new
  end

  # GET /custom_agents/1/edit
  def edit
  end

  # POST /custom_agents
  def create
    @custom_agent = CustomAgent.new(custom_agent_params)

    if @custom_agent.save
      redirect_to @custom_agent, notice: "Custom agent was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  # PATCH/PUT /custom_agents/1
  def update
    if @custom_agent.update(custom_agent_params)
      redirect_to @custom_agent, notice: "Custom agent was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /custom_agents/1
  def destroy
    @custom_agent.destroy!
    redirect_to custom_agents_path, notice: "Custom agent was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_custom_agent
      @custom_agent = CustomAgent.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def custom_agent_params
      params.expect(custom_agent: [ :name, :display_name, :description, :prompt ])
    end

    def add_custom_agents_breadcrumb
      add_breadcrumb("Custom Agents", custom_agents_path)
    end

    def add_custom_agent_breadcrumb
      add_breadcrumb(@custom_agent.id, custom_agent_path(@custom_agent))
    end
end
