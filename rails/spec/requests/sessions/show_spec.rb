# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /sessions/:id" do
  let!(:session) { Session.create!(id: SecureRandom.uuid, model: "gpt-4.1") }

  it "returns 200 and shows session" do
    get "/sessions/#{session.id}"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(session.model)
  end
end
