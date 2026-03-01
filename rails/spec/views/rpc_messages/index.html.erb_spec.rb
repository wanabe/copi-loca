# frozen_string_literal: true

require "rails_helper"

RSpec.describe "rpc_messages/index" do
  before do
    allow(Client).to receive(:create_session)
    session = Session.create!(id: "dummy", model: "gpt-4", created_at: Time.zone.now)
    assign(:session, session)
    assign(:methods, ["test_method"])
    assign(:selected_methods, [])
    assign(:selected_message_type, nil)
    assign(:selected_direction, nil)
    assign(:rpc_messages, Kaminari.paginate_array([
      RpcMessage.create!(
        session: session,
        direction: :outgoing,
        message_type: :request,
        rpc_id: "abc123",
        method: "test_method",
        params: {},
        result: nil,
        error: nil
      ),
      RpcMessage.create!(
        session: session,
        direction: :incoming,
        message_type: :response,
        rpc_id: "abc123",
        method: "test_method",
        params: nil,
        result: {},
        error: nil
      )
    ], total_count: 2).page(1))
  end

  it "renders a list of rpc_messages" do
    render
    css_selector = ".rpc-messages-flex-table .rpc-messages-flex-body .rpc-messages-flex-row"
    texts = css_select(css_selector).map { it.css("div").map(&:text) }
    expect(texts).to contain_exactly(include("abc123", "test_method", "request", "outgoing"),
      include("abc123", "test_method", "response", "incoming"))
  end
end
