require 'rails_helper'

RSpec.describe "events/show", type: :view do
  before(:each) do
    session = Session.create!(
      id: "Id",
      model: "Model",
    )
    assign(:event, Event.create!(
      session: session,
      rpc_message: RpcMessage.create!(session: session, direction: :incoming, message_type: :notification, method: "session.event", params: {}),
      event_type: "Event Type",
      event_id: "Id",
      data: "",
      ephemeral: false
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/ID:/)
    expect(rendered).to match(/Type:/)
    expect(rendered).to match(/Event ID:/)
    expect(rendered).to match(/Data:/)
    expect(rendered).to match(/Timestamp:/)
    expect(rendered).to match(/Parent:/)
  end
end
