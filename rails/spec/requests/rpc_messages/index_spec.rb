# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /sessions/:session_id/rpc_messages", type: :request do
  before do
    allow(Client).to receive(:create_session)
  end

  let(:session) { Session.create!(id: "dummy", model: "gpt-4.1") }

  let!(:older_rpc_message) do
    session.rpc_messages.create!(rpc_id: "1", method: "foo", direction: "outgoing", message_type: "request", params: {})
  end
  let!(:newer_rpc_message) do
    session.rpc_messages.create!(rpc_id: "2", method: "bar", direction: "incoming", message_type: "response",
      params: nil, result: {}, error: nil)
  end

  it "returns a successful response and renders the correct breadcrumbs" do
    get "/sessions/#{session.id}/rpc_messages"
    expect(response).to have_http_status(:success)

    breadcrumbs = css_select("li.breadcrumb-item a, li.breadcrumb-item span").map do |breadcrumb_item|
      [breadcrumb_item.attribute("href")&.value, breadcrumb_item.text.strip]
    end
    expect(breadcrumbs).to eq([
      [root_path, "Home"],
      [sessions_path, "Sessions"],
      [session_path(session), session.id.to_s],
      [nil, "RPC Messages"]
    ])
  end

  it "orders rpc_messages by id desc" do
    get "/sessions/#{session.id}/rpc_messages"
    expect(css_select(".rpc-messages-flex-body .rpc-col-method").map(&:text)).to eq([newer_rpc_message.method, older_rpc_message.method])
  end

  it "filters by method" do
    get "/sessions/#{session.id}/rpc_messages", params: { methods: ["foo"] }
    expect(css_select(".rpc-messages-flex-body .rpc-col-method").map(&:text)).to contain_exactly(older_rpc_message.method)
  end

  it "filters by direction" do
    get "/sessions/#{session.id}/rpc_messages", params: { direction: "incoming" }
    expect(css_select(".rpc-messages-flex-body .rpc-col-method").map(&:text)).to contain_exactly(newer_rpc_message.method)
  end

  it "filters by message_type" do
    get "/sessions/#{session.id}/rpc_messages", params: { message_type: "request" }
    expect(css_select(".rpc-messages-flex-body .rpc-col-method").map(&:text)).to contain_exactly(older_rpc_message.method)
  end
end
