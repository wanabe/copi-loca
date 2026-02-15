class RpcLogsController < ApplicationController
  include SessionRelated

  before_action :set_session
  before_action :set_rpc_log, only: %i[ show ]

  before_action :add_sessions_breadcrumb
  before_action :add_session_breadcrumb
  before_action :add_rpc_logs_breadcrumb
  before_action :add_rpc_log_breadcrumb, only: %i[ show ]

  # GET /sessions/:session_id/rpc_logs
  def index
    @rpc_logs = @session.rpc_logs.order(id: :desc).page(params[:page])
  end

  # GET /sessions/:session_id/rpc_logs/1
  def show
  end

  private
    def set_session
      @session = Session.find(params.expect(:session_id))
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_rpc_log
      @rpc_log = @session.rpc_logs.find(params.expect(:id))
    end

    def add_rpc_logs_breadcrumb
      add_breadcrumb("RPC Logs", session_rpc_logs_path(@session))
    end

    def add_rpc_log_breadcrumb
      add_breadcrumb(@rpc_log.id, session_rpc_log_path(@session, @rpc_log))
    end
end
