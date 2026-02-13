class MessagesController < ApplicationController
  before_action :set_session
  before_action :set_message, only: %i[ show ]

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
        tmp_path = Rails.root.join('tmp', "upload_#{SecureRandom.hex}_#{uploaded.original_filename}")
        File.open(tmp_path, 'wb') { |f| f.write(uploaded.read) }
        # Convert to copilot container path
        shared_paths << File.join('/shared-tmp', File.basename(tmp_path))
      end
    end
    if params[:camera_file].present?
      Array(params[:camera_file]).each do |uploaded|
        next unless uploaded.respond_to?(:original_filename)
        tmp_path = Rails.root.join('tmp', "upload_#{SecureRandom.hex}_#{uploaded.original_filename}")
        File.open(tmp_path, 'wb') { |f| f.write(uploaded.read) }
        shared_paths << File.join('/shared-tmp', File.basename(tmp_path))
      end
    end

    SendPromptJob.perform_later(@session.id, message_params[:content], shared_paths)

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
