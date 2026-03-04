# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /sessions/:id" do
  let!(:session) { Session.create!(id: SecureRandom.uuid, model: "gpt-4.1", current_tokens: 100, token_limit: 1000) }

  it "returns 200 and shows session" do
    get "/sessions/#{session.id}"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(session.model)
    expect(response.body).to include("Hide")
  end

  context "when close all" do
    it "shows open links" do
      get "/sessions/#{session.id}", params: { "show_messages" => "false", "show_events" => "false", "show_rpc_messages" => "false" }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Show")
      expect(response.body).not_to include("Hide")
    end
  end
end
