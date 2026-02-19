class MessagesController < ApplicationController
  include SessionRelated

  before_action :set_session
  before_action :set_message, only: %i[ show ]

  before_action :add_sessions_breadcrumb
  before_action :add_session_breadcrumb
  before_action :add_messages_breadcrumb
  before_action :add_message_breadcrumb, only: %i[ show ]

  # GET /messages
  def index
    @message = @session.messages.new
    @messages = @session.messages.order(id: :desc).page(params[:page])
  end

  # GET /messages/1
  def show
  end

  # POST /messages
  def create
    # Save uploaded files to tmp directory
    shared_paths = []
    if params[:file].present?
      Array(params[:file]).each do |uploaded|
        next unless uploaded.respond_to?(:original_filename)
        tmp_path = Rails.root.join("tmp", "upload_#{SecureRandom.hex}_#{uploaded.original_filename}")
        File.open(tmp_path, "wb") { |f| f.write(uploaded.read) }
        # Convert to copilot container path
        shared_paths << File.join("/shared-tmp", File.basename(tmp_path))
      end
    end
    if params[:camera_file].present?
      Array(params[:camera_file]).each do |uploaded|
        next unless uploaded.respond_to?(:original_filename)
        tmp_path = Rails.root.join("tmp", "upload_#{SecureRandom.hex}_#{uploaded.original_filename}")
        File.open(tmp_path, "wb") { |f| f.write(uploaded.read) }
        shared_paths << File.join("/shared-tmp", File.basename(tmp_path))
      end
    end

    content = message_params[:content].to_s.strip
    custom_agent_id = params[:custom_agent_id].to_s.strip
    if custom_agent_id.present?
      agent = @session.custom_agents.find_by(id: custom_agent_id)
      if agent
        content = "#{content} @#{agent.name}"
      end
    end
    if content.blank?
      respond_to do |format|
        format.turbo_stream { head :ok }
        format.html do
          if params[:from] == "session_show"
            redirect_to session_path(@session)
          else
            redirect_to action: :index
          end
        end
      end
      return
    end
    display_state = {
      show_messages: params[:show_messages],
      show_rpc_messages: params[:show_rpc_messages],
      show_events: params[:show_events]
    }
    SendPromptJob.perform_later(@session.id, content, shared_paths, display_state)

    respond_to do |format|
      format.turbo_stream { head :ok }
      format.html do
        if params[:from] == "session_show"
          redirect_to session_path(@session)
        else
          redirect_to action: :index
        end
      end
    end
  end

  private

    def set_session
      @session = Session.find(params.expect(:session_id))
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = @session.messages.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def message_params
      params.expect(message: [ :content ])
    end

    def add_messages_breadcrumb
      add_breadcrumb("Messages", session_messages_path(@session))
    end

    def add_message_breadcrumb
      add_breadcrumb(@message.id, session_message_path(@session, @message))
    end
end
