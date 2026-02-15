class RpcMessagesController < ApplicationController
  include SessionRelated

  before_action :set_session
  before_action :set_rpc_message, only: %i[ show ]

  before_action :add_sessions_breadcrumb
  before_action :add_session_breadcrumb
  before_action :add_rpc_messages_breadcrumb
  before_action :add_rpc_message_breadcrumb, only: %i[ show ]

  # GET /rpc_messages
  def index
    @rpc_messages = @session.rpc_messages.order(id: :desc).page(params[:page])
  end

  # GET /rpc_messages/1
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rpc_message
      @rpc_message = @session.rpc_messages.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def rpc_message_params
      params.fetch(:rpc_message, {})
    end

    def add_rpc_messages_breadcrumb
      add_breadcrumb("RPC Messages", session_rpc_messages_path(@session))
    end

    def add_rpc_message_breadcrumb
      add_breadcrumb(@rpc_message.id, session_rpc_message_path(@session, @rpc_message))
    end
end
