# frozen_string_literal: true

require "rails_helper"
require_relative "../../app/models/client"

describe Client do
  let(:copilot_client_double) do
    double = instance_double(Copilot::Client)
    allow(double).to receive(:on_send)
    allow(double).to receive(:on_receive)
    double
  end

  describe ".instance" do
    before do
      allow(Copilot::Client).to receive(:cache).and_return(copilot_client_double)
    end

    it "returns a singleton instance" do
      i1 = described_class.instance
      i2 = described_class.instance
      expect(i1).to equal(i2)
    end
  end

  describe "#initialize" do
    it "assigns copilot_client from Copilot::Client.cache" do
      allow(Copilot::Client).to receive(:cache).and_return(copilot_client_double)
      client = described_class.new
      expect(client.copilot_client).to eq(copilot_client_double)
    end

    it "executes on_send block" do
      allow(copilot_client_double).to receive(:on_send).and_yield({ params: { sessionId: 1 }, id: 2 })
      allow(copilot_client_double).to receive(:on_receive)
      allow(Copilot::Client).to receive(:cache).and_return(copilot_client_double)
      stub_const("Session", Class.new do
        def self.find_by(id:) = new
        def handle(*_args) = :handled
      end)
      allow(Rails.logger).to receive(:debug)
      expect { described_class.new }.not_to raise_error
    end

    it "executes on_receive block" do
      allow(copilot_client_double).to receive(:on_send)
      allow(copilot_client_double).to receive(:on_receive).and_yield({ params: { sessionId: 1 }, id: 2 })
      allow(Copilot::Client).to receive(:cache).and_return(copilot_client_double)
      stub_const("Session", Class.new do
        def self.find_by(id:) = new
        def handle(*_args) = :handled
      end)
      allow(Rails.logger).to receive(:debug)
      expect { described_class.new }.not_to raise_error
    end
  end

  describe "#create_session" do
    it "creates a copilot session and sets session id" do
      allow(copilot_client_double).to receive(:on_send)
      allow(copilot_client_double).to receive(:on_receive)
      allow(Copilot::Client).to receive(:cache).and_return(copilot_client_double)
      session = instance_double(Session, model: "gpt", options: {}, id: nil)
      copilot_session = instance_double(Copilot::Session, session_id: "sid")
      allow(copilot_client_double).to receive(:create_session).and_return(copilot_session)
      allow(session).to receive(:id=)
      described_class.new.create_session(session)
      expect(copilot_client_double).to have_received(:create_session).with(model: "gpt")
      expect(session).to have_received(:id=).with("sid")
    end
  end

  describe "#resume_session" do
    it "returns existing session if present" do
      allow(copilot_client_double).to receive(:on_send)
      allow(copilot_client_double).to receive(:on_receive)
      allow(Copilot::Client).to receive(:cache).and_return(copilot_client_double)
      session = instance_double(Session, id: "sid", options: {})
      allow(copilot_client_double).to receive(:sessions).and_return({ "sid" => :existing })
      expect(described_class.new.resume_session(session)).to eq(:existing)
    end

    it "creates session if not present" do
      allow(copilot_client_double).to receive(:on_send)
      allow(copilot_client_double).to receive(:on_receive)
      allow(Copilot::Client).to receive(:cache).and_return(copilot_client_double)
      session = instance_double(Session, id: "sid", options: {})
      allow(copilot_client_double).to receive_messages(sessions: {}, create_session: :created)
      described_class.new.resume_session(session)
      expect(copilot_client_double).to have_received(:create_session).with(session_id: "sid")
    end
  end

  describe "#available_models" do
    it "returns sorted models and caches them" do
      allow(copilot_client_double).to receive(:on_send)
      allow(copilot_client_double).to receive(:on_receive)
      allow(Copilot::Client).to receive(:cache).and_return(copilot_client_double)
      models = [
        { id: "b", billing: { multiplier: 2 } },
        { id: "a", billing: { multiplier: 1 } }
      ]
      allow(copilot_client_double).to receive_messages(call: :call_id, await: { models: models })
      client = described_class.new
      client.available_models
      expect(copilot_client_double).to have_received(:call).with("models.list")
      expect(copilot_client_double).to have_received(:await).with(:call_id)
      expect(client.available_models.pluck(:id)).to eq(%w[a b])
      # cached
      expect(client.available_models.pluck(:id)).to eq(%w[a b])
    end
  end

  describe "#wait" do
    it "yields last_rpc_message and resets it" do
      allow(copilot_client_double).to receive(:on_send).and_yield({ params: { sessionId: 1 }, id: 2 })
      allow(copilot_client_double).to receive(:on_receive)
      allow(copilot_client_double).to receive(:wait).and_yield
      allow(Copilot::Client).to receive(:cache).and_return(copilot_client_double)
      stub_const("Session", Class.new do
        def self.find_by(id:) = new
        def handle(*_args) = "msg"
      end)
      allow(Rails.logger).to receive(:debug)
      client = described_class.new
      yielded = nil
      client.wait { |m| yielded = m }
      expect(yielded).to eq("msg")
      client.wait { |m| expect(m).to be_nil }
    end
  end
end
