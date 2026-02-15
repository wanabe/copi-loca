require 'rails_helper'

RSpec.describe "rpc_messages/index", type: :view do
  before(:each) do
    session = Session.create!(model: "gpt-4", created_at: Time.now)
    assign(:session, session)
    assign(:methods, [ "test_method" ])
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
    cell_selector = 'div>p'
  end
end
