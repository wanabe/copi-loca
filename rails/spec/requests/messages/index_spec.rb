require 'rails_helper'

RSpec.describe "GET /sessions/:session_id/messages", type: :request do
  let(:session) { Session.create!(id: SecureRandom.uuid, model: "gpt-4.1") }
  let(:rpc_message) { RpcMessage.create!(session: session, direction: 1, message_type: 1, method: "test", params: {}, rpc_id: "rpc1") }
  let!(:message) { session.messages.create!(content: "hello", rpc_message: rpc_message, direction: 1) }

  it "returns 200 and lists messages" do
    get "/sessions/#{session.id}/messages"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("hello")
  end
end
