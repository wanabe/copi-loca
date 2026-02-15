require 'rails_helper'

RSpec.describe "rpc_messages/show", type: :view do
  before(:each) do
    session = Session.create!(model: "gpt-4", created_at: Time.now)
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
    allow(view).to receive_message_chain(:main_app, :session_rpc_messages_path).and_return("/sessions/#{session.id}/rpc_messages")
  end

  it "renders attributes in <p>" do
    render
  end
end
