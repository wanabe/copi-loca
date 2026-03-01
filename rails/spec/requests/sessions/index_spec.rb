# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /sessions", type: :request do
  let!(:session) { Session.create!(id: SecureRandom.uuid, model: "gpt-4.1") }

  it "returns 200 and lists sessions" do
    get "/sessions"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(session.id)
    expect(response.body).to include("Sessions")
  end
end
