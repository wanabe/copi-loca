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
    @message = @session.messages.new(message_params.merge(direction: :outgoing))

    if @message.save
      @session.close_after_idle
      redirect_to action: :index, notice: "Message was successfully created."
    else
      @messages = @session.messages.all
      render :index, status: :unprocessable_content
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
