class SessionsController < ApplicationController
  include SessionRelated
  before_action :set_session, only: %i[ show update edit destroy ]

  before_action :add_sessions_breadcrumb
  before_action :add_session_breadcrumb, only: %i[ show edit ]
  before_action :add_action_breadcrumb, only: %i[ new edit ]

  # GET /sessions
  def index
    @sessions = Session.all
  end

  # GET /sessions/1
  def show
    @display_state = {
      show_messages: params[:show_messages].presence_in(%w[ open true false ]) || "open",
      show_rpc_messages: params[:show_rpc_messages].presence_in(%w[ true false ]) || "true",
      show_events: params[:show_events].presence_in(%w[ true false ]) || "true"
    }
  end

  # GET /sessions/new
  def new
    @session = Session.new(skill_directory_pattern: "/app/.github/skills/*")
    @models = available_models
    @custom_agents = CustomAgent.all
    @tools = Tool.all
  end

  # GET /sessions/1/edit
  def edit
    @models = [ @session.model ]
    @custom_agents = CustomAgent.all
    @tools = Tool.all
  end

  # POST /sessions
  def create
    @session = Session.new(session_params)

    if @session.save
      redirect_to @session, notice: "Session was successfully created."
    else
      @models = available_models
      @custom_agents = CustomAgent.all
      @tools = Tool.all
      render :new, status: :unprocessable_content, alert: @session.errors.full_messages.to_sentence
    end
  end

  # PATCH/PUT /sessions/1
  def update
    if @session.update(session_params)
      redirect_to @session, notice: "Session was successfully updated.", status: :see_other
    else
      @models = [ @session.model ]
      @custom_agents = CustomAgent.all
      @tools = Tool.all
      render :edit, status: :unprocessable_content, alert: @session.errors.full_messages.to_sentence
    end
  end

  # DELETE /sessions/1
  def destroy
    @session.destroy!
    redirect_to sessions_path, notice: "Session was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def session_id_param
     params.require(:id)
    end

    # Only allow a list of trusted parameters through.
    def session_params
      params.fetch(:session, {}).permit(
        :model,
        :skill_directory_pattern,
        :system_message_mode,
        :system_message,
        custom_agent_ids: [],
        tool_ids: [],
      )
    end

    def available_models
      Client.available_models.map do |model|
        [ "#{model[:id]} (x#{model.dig(:billing, :multiplier)})", model[:id] ]
      end
    end
end
