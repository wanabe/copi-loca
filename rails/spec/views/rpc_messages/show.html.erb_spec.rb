# frozen_string_literal: true

require "rails_helper"

RSpec.describe "rpc_messages/show" do
  before do
    allow(Client).to receive(:create_session)
    session = Session.create!(id: "dummy", model: "gpt-4", created_at: Time.zone.now)
    assign(:session, session)
    assign(:rpc_message, RpcMessage.create!(
      session: session,
      direction: :outgoing,
      message_type: :request,
      rpc_id: "abc123",
      method: "test_method",
      params: {},
      result: nil,
      error: nil
    ))
    allow(view.main_app).to receive(:session_rpc_messages_path).and_return("/sessions/#{session.id}/rpc_messages")
  end

  it "renders attributes in <p>" do
    render
    css_selector = ".rpc-message"
    texts = css_select(css_selector).map { |element| element.css("div").map(&:text) }
    expect(texts).to contain_exactly(include("abc123", "test_method", "request", "outgoing"))
  end
end
