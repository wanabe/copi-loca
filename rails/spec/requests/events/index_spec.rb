# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /events" do
  let!(:session) { Session.create!(id: "sess1", model: "test_model") }
  let!(:rpc_message) { RpcMessage.create!(session: session, params: {}, method: "test_method") }
  let!(:event) { Event.create!(session: session, event_id: "evt1", rpc_message: rpc_message, event_type: "test") }

  it "renders a successful response" do
    get session_events_path(session_id: session.id)
    expect(response).to be_successful
    expect(response.body).to include(event.event_id)
    expect(response.body).to include(event.session_id)
    expect(response.body).to include(event.event_type)
  end
end
