class SessionsController < ApplicationController
  before_action :set_session, only: %i[ show destroy ]

  # GET /sessions
  def index
    @session = Session.new
    @sessions = Session.all
    @models = Client.available_models.map do |model|
      [ "#{model[:id]} (x#{model.dig(:billing, :multiplier)})", model[:id] ]
    end
  end

  # GET /sessions/1
  def show
  end

  # POST /sessions
  def create
    unless session[:admin] || ENV['COPI_ADMIN_PASSWORD'].blank?
      redirect_to new_auth_session_path, alert: 'Admin only.' and return
    end
    @session = Session.new(session_params)

    if @session.save
      redirect_to @session, notice: "Session was successfully created."
    else
      render :index, status: :unprocessable_content
    end
  end

  # DELETE /sessions/1
  def destroy
    unless session[:admin] || ENV['COPI_ADMIN_PASSWORD'].blank?
      redirect_to new_auth_session_path, alert: 'Admin only.' and return
    end
    @session.destroy!
    redirect_to sessions_path, notice: "Session was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_session
      @session = Session.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def session_params
      params.fetch(:session, {}).permit(:model)
    end
end
