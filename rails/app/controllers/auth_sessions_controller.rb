# frozen_string_literal: true

class AuthSessionsController < ApplicationController
  skip_before_action :authenticate, only: %i[new create]

  def new
    render Views::AuthSessions::New.new
  end

  def create
    if params[:password] == ENV["COPI_ADMIN_PASSWORD"]
      session[:admin] = true
      redirect_to root_path, notice: "Logged in successfully."
    else
      redirect_to new_auth_session_path, alert: "Invalid password."
    end
  end

  def destroy
    session[:admin] = nil
    redirect_to root_path, notice: "Logged out."
  end
end
