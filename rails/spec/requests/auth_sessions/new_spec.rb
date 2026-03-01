# frozen_string_literal: true

require "rails_helper"

describe "GET /auth_sessions/new", type: :request do
  it "renders the login form" do
    get "/auth_sessions/new"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Login")
    expect(response.body).to include("Password:")
  end
end
