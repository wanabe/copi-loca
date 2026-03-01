# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /sessions/:session_id/rpc_messages/:id" do
  before do
    allow(Client).to receive(:create_session)
  end

  let(:session) { Session.create!(id: "dummy", model: "gpt-4.1") }

  let!(:rpc_message) do
    session.rpc_messages.create!(rpc_id: "1", method: "foo", direction: "outgoing", message_type: "request",
      params: { key: "value" })
  end

  it "returns a successful response and renders the correct breadcrumbs" do
    get "/sessions/#{session.id}/rpc_messages/#{rpc_message.id}"
    expect(response).to have_http_status(:success)

    breadcrumbs = css_select("li.breadcrumb-item a, li.breadcrumb-item span").map do |breadcrumb_item|
      [breadcrumb_item.attribute("href")&.value, breadcrumb_item.text.strip]
    end
    expect(breadcrumbs).to eq([
      [root_path, "Home"],
      [sessions_path, "Sessions"],
      [session_path(session), session.id.to_s],
      [session_rpc_messages_path(session), "RPC Messages"],
      [nil, rpc_message.id.to_s]
    ])
  end

  it "shows the correct rpc_message details" do
    get "/sessions/#{session.id}/rpc_messages/#{rpc_message.id}"
    expect(response.body).to include(rpc_message.method)
    expect(response.body).to include(rpc_message.direction)
    expect(response.body).to include(rpc_message.message_type)
    expect(response.body).to include(rpc_message.rpc_id)
  end
end
