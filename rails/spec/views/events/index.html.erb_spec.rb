# frozen_string_literal: true

require "rails_helper"

RSpec.describe "events/index", type: :view do
  before do
    allow(Client).to receive(:create_session)
    session = Session.create!(id: "dummy", model: "Model")
    assign(:session, session)
    assign(:types, [])
    assign(:events, Kaminari.paginate_array([
      Event.create!(
        session: session,
        rpc_message: RpcMessage.create!(session: session, direction: :incoming, message_type: :notification,
          method: "session.event", params: {}),
        event_type: "type1",
        event_id: "event1",
        data: "{\"key\": \"value1\"}",
        ephemeral: false
      ),
      Event.create!(
        session: session,
        rpc_message: RpcMessage.create!(session: session, direction: :incoming, message_type: :notification,
          method: "session.event", params: {}),
        event_type: "type2",
        event_id: "event2",
        data: "{\"key\": \"value2\"}",
        ephemeral: false
      )
    ]).page(1))
  end

  it "renders a list of events" do
    render
    expect(css_select(".events-flex-header > div").map(&:text)).to eq(["ID", "Event type", "Event ID", "Data",
                                                                       "Timestamp", "Parent"])
    expect(css_select(".events-flex-body .events-col-type").map(&:text)).to eq(%w[type1 type2])
    expect(css_select(".events-flex-body .events-col-eventid").map(&:text)).to eq(%w[event1 event2])
  end
end
