require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  let!(:session) { Session.create!(id: SecureRandom.uuid, model: "gpt-4.1") }

  describe "GET /sessions" do
    it "returns 200 and lists sessions" do
      get "/sessions"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(session.id)
      expect(response.body).to include("Sessions")
    end
  end

  describe "GET /sessions/:id" do
    it "returns 200 and shows session" do
      get "/sessions/#{session.id}"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(session.model)
    end
  end
end
