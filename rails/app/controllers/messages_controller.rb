class MessagesController < ApplicationController
  before_action :set_session
  before_action :set_message, only: %i[ show ]

  # GET /messages
  def index
    @message = @session.messages.new
    @messages = @session.messages.all
  end

  # GET /messages/1
  def show
  end

  # POST /messages
  def create
    SendPromptJob.perform_later(@session.id, message_params[:content])

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
end
