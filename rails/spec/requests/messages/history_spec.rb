# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /sessions/:session_id/messages/history", type: :request do
  let(:session) { Session.create!(id: SecureRandom.uuid, model: "gpt-4.1") }
  let(:rpc_message) do
    RpcMessage.create!(session: session, direction: 1, message_type: 1, method: "test", params: {}, rpc_id: "rpc1")
  end
  let!(:message) { session.messages.create!(content: "hello", rpc_message: rpc_message, direction: :outgoing) }

  it "returns 200 for history partial" do
    get "/sessions/#{session.id}/messages/history"
    expect(response.status).to eq(200)
    expect(response.body).to include(message.content)
  end
end
