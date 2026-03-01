# frozen_string_literal: true

class AuthSessionsController < ApplicationController
  skip_before_action :authenticate, only: %i[new create]

  def new; end

  def create
    if params[:password] == ENV["COPI_ADMIN_PASSWORD"]
      session[:admin] = true
      redirect_to root_path, notice: "Logged in successfully."
    else
      flash.now[:alert] = "Invalid password."
      render :new
    end
  end

  def destroy
    session[:admin] = nil
    redirect_to root_path, notice: "Logged out."
  end
end
