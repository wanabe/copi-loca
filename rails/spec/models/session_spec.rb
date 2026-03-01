# frozen_string_literal: true

require "rails_helper"

RSpec.describe Session do
  let(:copilot_session) { instance_double(Copilot::Session) }

  before do
    allow(Client).to receive(:create_session) do |session|
      session.id = SecureRandom.uuid
      copilot_session
    end
  end

  describe "validations" do
    it "is valid with default attributes" do
      session = described_class.new(model: "test")
      expect(session).to be_valid
    end
  end

  describe "after_initialize callback" do
    it "sets @copilot_session to nil" do
      session = described_class.new(model: "test")
      expect(session.instance_variable_get(:@copilot_session)).to be_nil
    end
  end

  describe "before_destroy callback" do
    it "deletes associated messages, rpc_messages, events, session_custom_agents, session_tools" do
      session = described_class.create!(model: "test")
      rpc_message = RpcMessage.create!(session: session, direction: :outgoing, message_type: :request, rpc_id: "id",
        method: "foo", params: {})
      Message.create!(session: session, content: "c", direction: :outgoing, rpc_message_id: rpc_message.id)
      Event.create!(session: session, rpc_message: rpc_message, event_id: "e", event_type: "t", data: {},
        timestamp: Time.zone.now)
      agent = CustomAgent.create!(name: "agent")
      SessionCustomAgent.create!(session: session, custom_agent: agent)
      tool = Tool.create!(name: "tool")
      SessionTool.create!(session_id: session.id, tool: tool)
      session.destroy
      expect(Message.where(session_id: session.id)).to be_empty
      expect(RpcMessage.where(session_id: session.id)).to be_empty
      expect(Event.where(session_id: session.id)).to be_empty
      expect(SessionCustomAgent.where(session_id: session.id)).to be_empty
      expect(SessionTool.where(session_id: session.id)).to be_empty
    end
  end

  describe "system_message_mode enum" do
    it "has correct values" do
      expect(described_class.system_message_modes).to eq({ "default" => 0, "replace" => 1, "append" => 2 })
    end
  end

  describe "#options" do
    describe "about systemMessage" do
      it "returns systemMessage if AGENTS.md exists" do
        allow(File).to receive(:exist?).with("/app/AGENTS.md").and_return(true)
        allow(File).to receive(:read).with("/app/AGENTS.md").and_return("dummy")
        session = described_class.new(model: "test")
        options = session.options
        expect(options).to have_key(:systemMessage)
        expect(options[:systemMessage][:mode]).to eq("append")
        expect(options[:systemMessage][:content]).to include("<attachments path=\"/app/AGENTS.md\">\ndummy\n</attachments>")
      end

      it "returns systemMessage with mode replace if system_message_mode is replace" do
        session = described_class.new(model: "test", system_message_mode: :replace, system_message: "replace_msg")
        options = session.options
        expect(options).to have_key(:systemMessage)
        expect(options[:systemMessage][:mode]).to eq("replace")
        expect(options[:systemMessage][:content]).to eq("replace_msg")
      end

      it "returns systemMessage with mode append if system_message_mode is append and system_message present" do
        allow(File).to receive(:exist?).with("/app/AGENTS.md").and_return(false)
        session = described_class.new(model: "test", system_message_mode: :append, system_message: "append_msg")
        options = session.options
        expect(options).to have_key(:systemMessage)
        expect(options[:systemMessage][:mode]).to eq("append")
        expect(options[:systemMessage][:content]).to include("append_msg")
      end

      it "returns empty options if no branches matched" do
        allow(File).to receive(:exist?).with("/app/AGENTS.md").and_return(false)
        session = described_class.new(model: "test", system_message_mode: :default, system_message: nil)
        allow(session).to receive_messages(custom_agents: [], tools: [])
        options = session.options
        expect(options).to eq({})
      end
    end

    describe "about customAgents" do
      it "includes customAgents in options if present" do
        session = described_class.new(model: "test")
        agent = CustomAgent.new(name: "agent", prompt: "prompt", description: "desc")
        SessionCustomAgent.build(session: session, custom_agent: agent)
        allow(session).to receive(:custom_agents).and_return([agent])
        options = session.options
        expect(options).to have_key(:customAgents)
        expect(options[:customAgents].first[:name]).to eq("agent")
      end
    end

    describe "about tools" do
      it "includes tools in options if present" do
        session = described_class.new(model: "test")
        tool = Tool.new(name: "tool", description: "desc")
        tool.tool_parameters.build(name: "param", description: "param_desc")
        allow(session).to receive(:tools).and_return([tool])
        options = session.options
        expect(options).to have_key(:tools)
        expect(options[:tools].first[:name]).to eq("tool")
        expect(options[:tools].map { |t| t[:parameters][:properties].keys }).to eq([["param"]])
      end
    end

    describe "about skillDirectories" do
      it "includes skillDirectories in options if pattern matches" do
        session = described_class.new(model: "test", skill_directory_pattern: "rails")
        allow(Dir).to receive(:glob).and_return(["rails/SKILL.md"])
        options = session.options
        expect(options).to have_key(:skillDirectories)
        expect(options[:skillDirectories]).to include("rails")
      end
    end
  end

  describe "#send_prompt" do
    it "creates message if rpc_message found" do
      session = described_class.create!(model: "test")
      rpc_message = RpcMessage.new(direction: :outgoing, message_type: :request, rpc_id: "rpc123", method: "foo",
        params: {})
      allow(session).to receive_messages(copilot_session: instance_double(Copilot::Session, send: "rpc123"),
        rpc_messages: instance_double(ActiveRecord::Relation, find_by: rpc_message))
      allow(session.messages).to receive(:create!).and_return(true)
      session.send_prompt("prompt")
      expect(session.messages).to have_received(:create!).with(content: "prompt", direction: :outgoing,
        rpc_message: rpc_message)
    end

    it "raises error and does not create message if rpc_message not found" do
      session = described_class.new(model: "test")
      allow(session).to receive_messages(copilot_session: instance_double(Copilot::Session, send: "rpc123"),
        rpc_messages: instance_double(ActiveRecord::Relation, find_by: nil))
      allow(session.messages).to receive(:create!)
      expect do
        session.send_prompt("prompt")
      end.to raise_error("RPC message not found for sent prompt with RPC ID: rpc123")
      expect(session.messages).not_to have_received(:create!)
    end

    it "resumes session and reuses it" do
      session = described_class.new(model: "test")
      copilot_session = instance_double(Copilot::Session, send: "rpc123")
      allow(Client).to receive(:resume_session).and_return(copilot_session)
      rpc_message = RpcMessage.new
      allow(session).to receive(:rpc_messages).and_return(instance_double(ActiveRecord::Relation, find_by: rpc_message))
      allow(session.messages).to receive(:create!).and_return(true)

      session.send_prompt("prompt")
      expect(Client).to have_received(:resume_session).once
      expect(copilot_session).to have_received(:send).with("prompt", hash_including(:attachments))
      expect(session.messages).to have_received(:create!).with(content: "prompt", direction: :outgoing,
        rpc_message: rpc_message)
      session.send_prompt("prompt2")
      expect(Client).to have_received(:resume_session).once
      expect(copilot_session).to have_received(:send).with("prompt2", hash_including(:attachments))
      expect(session.messages).to have_received(:create!).with(content: "prompt2", direction: :outgoing,
        rpc_message: rpc_message)
    end
  end

  describe "#handle" do
    it "creates rpc_message and calls handle" do
      session = described_class.new(model: "test")
      rpc_message = instance_double(RpcMessage, handle: true)
      rpc_messages = instance_double(ActiveRecord::Relation, create!: rpc_message)
      allow(session).to receive(:rpc_messages).and_return(rpc_messages)
      session.handle(:outgoing, "rpcid", { method: "foo", params: {}, result: {}, error: nil })
      expect(rpc_messages).to have_received(:create!).with(hash_including(direction: :outgoing, rpc_id: "rpcid",
        method: "foo", params: {}, result: {}, error: nil))
      expect(rpc_message).to have_received(:handle)
    end
  end

  describe "#close_after_idle" do
    it "calls wait_until_idle and then close_session" do
      session = described_class.new(model: "test")
      called = []
      allow(session).to receive(:wait_until_idle) { called << :wait }
      allow(session).to receive(:close_session) { called << :close }

      session.close_after_idle

      expect(called).to eq(%i[wait close])
    end
  end

  describe "#wait_until_idle" do
    it "invokes the provided block with rpc_message and returns Client.wait result" do
      # ensure a copilot session exists so @copilot_session.idle? does not raise
      copilot_double = instance_double(Copilot::Session, idle?: true)
      allow(Client).to receive(:create_session) do |s|
        s.id = SecureRandom.uuid
        copilot_double
      end
      session = described_class.create!(model: "test")

      rpc_message = instance_double(RpcMessage, session_id: session.id)

      allow(Client).to receive(:wait).and_yield(rpc_message).and_return(true)

      called_rpc = nil
      result = session.wait_until_idle do |rm|
        called_rpc = rm
      end

      expect(called_rpc).to eq(rpc_message)
      expect(result).to be true
      expect(Client).to have_received(:wait)
    end

    it "returns Client.wait result when no block given" do
      copilot_double = instance_double(Copilot::Session, idle?: false)
      allow(Client).to receive(:create_session) do |s|
        s.id = SecureRandom.uuid
        copilot_double
      end
      session = described_class.create!(model: "test")
      allow(Client).to receive(:wait).and_return(false)
      expect(session.wait_until_idle).to be false
      expect(Client).to have_received(:wait)
    end
  end

  describe "#close_session" do
    context "when instance is built" do
      it "does nothing and does not raise" do
        session = described_class.new(model: "test")
        expect { session.close_session }.not_to raise_error
      end
    end

    context "when copilot session is resumed via send_prompt" do
      it "destroys the created copilot session" do
        copilot_double = instance_double(Copilot::Session)
        allow(copilot_double).to receive(:send).and_return("rpc-123")
        allow(copilot_double).to receive(:destroy)

        # ensure create does not set a copilot session so resume_session will be used
        allow(Client).to receive(:create_session) do |s|
          s.id = SecureRandom.uuid
          nil
        end
        session = described_class.create!(model: "test")

        allow(Client).to receive(:resume_session).with(session).and_return(copilot_double)

        # create matching rpc_message so send_prompt can find it
        session.rpc_messages.create!(direction: :incoming, rpc_id: "rpc-123", method: "test", params: {})

        # trigger resume_session via send_prompt
        session.send_prompt("hello")
        expect(copilot_double).to have_received(:send).with("hello", hash_including(:attachments))

        # calling close_session should destroy the copilot session
        session.close_session
        expect(copilot_double).to have_received(:destroy)
      end
    end
  end
end
