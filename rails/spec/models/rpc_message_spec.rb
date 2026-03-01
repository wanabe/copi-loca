# frozen_string_literal: true

require "rails_helper"

RSpec.describe RpcMessage, type: :model do
  before do
    allow(Client).to receive(:create_session)
  end

  describe "#initialize" do
    it "sets direction and message_type" do
      rpc_message = described_class.new(direction: :outgoing, message_type: :request, rpc_id: "id", method: "foo",
        params: {})
      expect(rpc_message.direction).to eq("outgoing")
      expect(rpc_message.message_type).to eq("request")
    end
  end

  describe "#handle" do
    let(:session) { Session.create!(id: "dummy", model: "test") }

    it "does nothing if not incoming" do
      rpc_message = described_class.create!(session: session, direction: :outgoing, message_type: :request, rpc_id: "id",
        method: "foo", params: {})
      expect { rpc_message.handle }.not_to(change(Event, :count))
    end

    it "does nothing if method is not session.event" do
      rpc_message = described_class.create!(session: session, direction: :incoming, message_type: :request, rpc_id: "id",
        method: "other", params: { "event" => { "id" => "e" } })
      expect { rpc_message.handle }.not_to(change(Event, :count))
    end

    it "does nothing if params['event'] is nil" do
      rpc_message = described_class.create!(session: session, direction: :incoming, message_type: :request, rpc_id: "id",
        method: "session.event", params: {})
      expect { rpc_message.handle }.not_to(change(Event, :count))
    end

    it "creates event without parent if parentId is nil" do
      rpc_message = described_class.create!(
        session: session, direction: :incoming, message_type: :request, rpc_id: "id", method: "session.event",
        params: { "event" => { "id" => "e", "type" => "t", "data" => {}, "timestamp" => Time.zone.now, "ephemeral" => false } }
      )
      expect { rpc_message.handle }.to change(Event, :count).by(1)
      event = Event.last
      expect(event.event_id).to eq("e")
      expect(event.parent_event_id).to be_nil
    end

    it "creates event with parent if parentId is present" do
      parent = Event.create!(
        session: session,
        rpc_message: described_class.create!(
          session: session, direction: :incoming, message_type: :request, rpc_id: "pid", method: "session.event", params: { "event" => {
            "id" => "pid", "type" => "t", "data" => {}, "timestamp" => Time.zone.now, "ephemeral" => false
          } }
        ), event_id: "pid", event_type: "t", data: {}, timestamp: Time.zone.now
      )
      rpc_message = described_class.create!(
        session: session, direction: :incoming, message_type: :request, rpc_id: "id",
        method: "session.event", params: {
          "event" => {
            "id" => "e", "type" => "t", "data" => {}, "timestamp" => Time.zone.now, "ephemeral" => false,
            "parentId" => "pid"
          }
        }
      )
      expect { rpc_message.handle }.to change(Event, :count).by(1)
      event = Event.last
      expect(event.event_id).to eq("e")
      expect(event.parent_event_id).to eq(parent.id)
    end
  end

  describe "before_validation callback" do
    it "sets message_type to request when method, params present and rpc_id present" do
      rpc_message = described_class.new(method: "foo", params: { a: 1 }, rpc_id: "id", result: nil, error: nil)
      rpc_message.valid?
      expect(rpc_message.message_type).to eq("request")
    end

    it "sets message_type to notification when method, params present and rpc_id absent" do
      rpc_message = described_class.new(method: "foo", params: { a: 1 }, rpc_id: nil, result: nil, error: nil)
      rpc_message.valid?
      expect(rpc_message.message_type).to eq("notification")
    end

    it "sets message_type to response when rpc_id present, params nil, and result present" do
      rpc_message = described_class.new(method: nil, params: nil, rpc_id: "id", result: "ok", error: nil)
      rpc_message.valid?
      expect(rpc_message.message_type).to eq("response")
    end

    it "does not set message_type for unexpected attribute combinations" do
      rpc_message = described_class.new(method: nil, params: nil, rpc_id: nil, result: nil, error: nil)
      rpc_message.message_type = nil
      rpc_message.valid?
      expect(rpc_message.message_type).to be_nil
    end
  end

  describe "before_save callback" do
    let(:session) { Session.new }

    it "infers method for response when request exists" do
      session = Session.create!(id: "dummy", model: "test")
      described_class.create!(session: session, rpc_id: "id", message_type: :request, method: "foo",
        direction: :outgoing, params: {})
      response = described_class.new(session: session, rpc_id: "id", message_type: :response, method: nil,
        direction: :incoming, result: "ok")
      response.save
      expect(response.method).to eq("foo")
    end

    it "does not infer method for response when request does not exist" do
      session = Session.create!(id: "dummy", model: "test")
      response = described_class.new(session: session, rpc_id: "id", message_type: :response, method: nil,
        direction: :incoming, result: "ok")
      response.save
      expect(response.method).to be_nil
    end

    it "does not infer method for non-response message_type" do
      session = Session.create!(id: "dummy", model: "test")
      described_class.create!(session: session, rpc_id: "id", message_type: :request, method: "foo",
        direction: :outgoing, params: {})
      rpc_message = described_class.new(session: session, rpc_id: "id", message_type: :request, method: nil,
        direction: :incoming)
      rpc_message.save
      expect(rpc_message.method).to be_nil
    end
  end

  describe ".validations" do
    it "validates presence of direction and message_type" do
      rpc_message = described_class.new(direction: nil, message_type: nil)
      rpc_message.valid?
      expect(rpc_message.errors[:direction]).to be_present
      expect(rpc_message.errors[:message_type]).to be_present
    end

    it "validates conditional fields for request type" do
      rpc_message = described_class.new(direction: :incoming, message_type: :request, rpc_id: nil, method: "foo",
        params: { a: 1 }, result: nil, error: nil)
      allow(rpc_message).to receive(:set_message_type)
      rpc_message.valid?
      expect(rpc_message.errors[:rpc_id]).to be_present
      expect(rpc_message.errors[:method]).to be_blank
      expect(rpc_message.errors[:params]).to be_blank
      expect(rpc_message.errors[:result]).to be_blank
      expect(rpc_message.errors[:error]).to be_blank
    end

    it "validates conditional fields for response type" do
      rpc_message = described_class.new(direction: :incoming, message_type: :response, rpc_id: "id", method: nil,
        params: nil, result: "ok", error: nil)
      allow(rpc_message).to receive(:set_message_type)
      rpc_message.valid?
      expect(rpc_message.errors[:rpc_id]).to be_blank
      expect(rpc_message.errors[:method]).to be_blank
      expect(rpc_message.errors[:params]).to be_blank
      expect(rpc_message.errors[:result]).to be_blank
      expect(rpc_message.errors[:error]).to be_blank
    end

    it "validates conditional fields for notification type" do
      rpc_message = described_class.new(direction: :incoming, message_type: :notification, rpc_id: nil, method: "foo",
        params: { a: 1 }, result: nil, error: nil)
      allow(rpc_message).to receive(:set_message_type)
      rpc_message.valid?
      expect(rpc_message.errors[:rpc_id]).to be_blank
      expect(rpc_message.errors[:method]).to be_blank
      expect(rpc_message.errors[:params]).to be_blank
      expect(rpc_message.errors[:result]).to be_blank
      expect(rpc_message.errors[:error]).to be_blank
    end
  end
end
