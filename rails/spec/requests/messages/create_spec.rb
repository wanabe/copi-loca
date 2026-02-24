require 'rails_helper'

RSpec.describe "Messages", type: :request do
  let(:session) { Session.create!(id: SecureRandom.uuid, model: "gpt-4.1") }

  describe "POST /sessions/:session_id/messages" do
    it "creates a message async and redirects" do
      allow(SendPromptJob).to receive(:perform_later)
      post "/sessions/#{session.id}/messages", params: { message: { content: "new message" } }
      expect(response).to have_http_status(:found)
      follow_redirect!
      expect(SendPromptJob).to have_received(:perform_later)
    end
  end
end
