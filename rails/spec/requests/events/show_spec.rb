# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /events/:id" do
  let!(:session) { Session.create!(id: "sess1", model: "test_model") }
  let!(:rpc_message) { RpcMessage.create!(session: session, params: {}, method: "test_method") }
  let!(:event) { Event.create!(event_id: "evt1", session: session, rpc_message: rpc_message, event_type: "test") }

  it "renders a successful response" do
    get session_event_url(session, event)
    expect(response).to be_successful
    expect(response.body).to include(event.event_id)
    expect(response.body).to include(event.session_id)
    expect(response.body).to include(event.event_type)
  end

  context "when event has parent event" do
    let!(:parent_event) { Event.create!(event_id: "evt_parent", session: session, rpc_message: rpc_message, event_type: "parent") }
    let!(:child_event) do
      Event.create!(event_id: "evt_child", session: session, rpc_message: rpc_message, event_type: "child", parent_event: parent_event)
    end

    it "displays parent event link" do
      get session_event_url(session, child_event)
      expect(response).to be_successful
      expect(response.body).to include(session_event_path(session, parent_event))
    end
  end
end
