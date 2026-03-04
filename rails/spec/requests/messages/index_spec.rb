# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /sessions/:session_id/messages" do
  let(:session) { Session.create!(id: SecureRandom.uuid, model: "gpt-4.1") }
  let(:rpc_message) do
    RpcMessage.create!(session: session, direction: 1, message_type: 1, method: "test", params: {}, rpc_id: "rpc1")
  end
  let(:old_rpc_message) do
    RpcMessage.create!(session: session, direction: 1, message_type: 1, method: "test", params: {}, rpc_id: "rpc_old", created_at: 3.days.ago)
  end

  before do
    session.messages.create!(content: "hello 1", rpc_message: old_rpc_message, direction: 1, created_at: 3.days.ago)
    session.messages.create!(content: "hello 2", rpc_message: rpc_message, direction: 1)
    session.messages.create!(content: "hello 3", rpc_message: rpc_message, direction: 1)
    session.messages.create!(content: "hello 4", rpc_message: rpc_message, direction: 1)
  end

  it "returns 200 and lists messages" do
    get "/sessions/#{session.id}/messages"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("hello")
  end

  it "paginates messages" do
    get "/sessions/#{session.id}/messages", params: { per_page: 1 }
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("hello 4")
    expect(response.body).not_to include("hello 1")
    # Check that only one message is shown on the first page
    expect(css_select(".messages-message__content").map(&:text)).to eq(["hello 4"])

    get "/sessions/#{session.id}/messages", params: { per_page: 1, page: 2 }
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("hello 3")
    expect(response.body).not_to include("hello 4")
    # Check that the other message is shown on the second page
    expect(css_select(".messages-message__content").map(&:text)).to eq(["hello 3"])

    get "/sessions/#{session.id}/messages", params: { per_page: 1, page: 3 }
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("hello 2")
    expect(response.body).not_to include("hello 3")
    # Check that the other message is shown on the third page
    expect(css_select(".messages-message__content").map(&:text)).to eq(["hello 2"])

    get "/sessions/#{session.id}/messages", params: { per_page: 1, page: 4 }
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("hello 1")
    expect(response.body).not_to include("hello 2")
    # Check that the other message is shown on the fourth page
    expect(css_select(".messages-message__content").map(&:text)).to eq(["hello 1"])
  end
end
