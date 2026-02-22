require 'rails_helper'

RSpec.describe Event, type: :model do
  describe "#handle" do
    context "assistant.message" do
      it "creates a message when content is present and parentToolCallId is blank" do
        session = Session.new
        rpc_message = RpcMessage.new
        event = described_class.new(event_type: "assistant.message", data: { "content" => "hi" }, session: session, rpc_message: rpc_message)
        allow(event.data).to receive(:[]).with("parentToolCallId").and_return(nil)
        allow(event.data).to receive(:[]).with("content").and_return("hi")
        allow(rpc_message).to receive(:create_message!)
        event.handle
        expect(rpc_message).to have_received(:create_message!).with(hash_including(session: session, direction: :incoming, content: "hi"))
      end
      it "does not create message if content is blank" do
        session = Session.new
        rpc_message = RpcMessage.new
        event = described_class.new(event_type: "assistant.message", data: { "content" => "" }, session: session, rpc_message: rpc_message)
        expect(rpc_message).not_to receive(:create_message!)
        event.handle
      end
      it "does not create message if parentToolCallId is present" do
        session = Session.new
        rpc_message = RpcMessage.new
        event = described_class.new(event_type: "assistant.message", data: { "content" => "hi", "parentToolCallId" => "tool" }, session: session, rpc_message: rpc_message)
        expect(rpc_message).not_to receive(:create_message!)
        event.handle
      end
    end

    context "session.usage_info" do
      it "updates session when values are present" do
        session = Session.new
        rpc_message = RpcMessage.new
        event = described_class.new(event_type: "session.usage_info", data: { "tokenLimit" => 100, "currentTokens" => 10 }, session: session, rpc_message: rpc_message)
        allow(session).to receive(:update!)
        event.handle
        expect(session).to have_received(:update!).with(token_limit: 100, current_tokens: 10)
      end
      it "does not update session if values are blank" do
        session = Session.new
        rpc_message = RpcMessage.new
        event = described_class.new(event_type: "session.usage_info", data: {}, session: session, rpc_message: rpc_message)
        expect(session).not_to receive(:update!)
        event.handle
      end
    end
  end
end
