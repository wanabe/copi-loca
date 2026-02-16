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
    @methods = @session.rpc_messages.distinct.pluck(:method).compact.sort || []
    @selected_methods = Array(params[:methods])
    @selected_direction = params[:direction]
    @selected_message_type = params[:message_type]
    scope = @session.rpc_messages
    scope = scope.where(method: @selected_methods) if @selected_methods.present?
    scope = scope.where(direction: @selected_direction) if @selected_direction.present?
    scope = scope.where(message_type: @selected_message_type) if @selected_message_type.present?
    @rpc_messages = scope.order(id: :desc).page(params[:page])
    @streaming = params[:page].nil? || params[:page].to_i == 1
  end

  # GET /rpc_messages/1
  def show
    @prev_rpc_message = @session.rpc_messages.where('id < ?', @rpc_message.id).order(id: :desc).first
    @next_rpc_message = @session.rpc_messages.where('id > ?', @rpc_message.id).order(id: :asc).first
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
