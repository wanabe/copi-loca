class RpcLogsController < ApplicationController
  before_action :set_session
  before_action :set_rpc_log, only: %i[ show ]

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
end
