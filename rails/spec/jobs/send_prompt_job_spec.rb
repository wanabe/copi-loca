require 'rails_helper'

RSpec.describe SendPromptJob, type: :job do
  let(:session) { instance_double(Session, id: "session1") }
  let(:prompt) { "test prompt" }
  let(:file_paths) { [ "/shared-tmp/dummy.txt" ] }
  let(:display_state) { { show_messages: true } }

  before do
    allow(Session).to receive(:find).and_return(session)
    allow(session).to receive(:send_prompt).and_return(:message)
    allow(session).to receive(:wait_until_idle).and_yield(:rpc_message)
    allow(session).to receive(:reload).and_return(session)
    allow(session).to receive(:close_session)
    allow(File).to receive(:exist?).and_return(true)
    allow(File).to receive(:delete)
    allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)
    allow(Rails).to receive_message_chain(:root, :join).and_return(Pathname.new("/tmp/dummy.txt"))
    allow(Time).to receive(:current).and_return(Time.now)
    allow(described_class).to receive(:new).and_wrap_original do |original_method, *args|
      job = original_method.call(*args)
      allow(job).to receive(:sleep)
      job
    end
  end

  it "calls send_prompt and broadcasts running/idle, including delayed re-render" do
    expect(session).to receive(:send_prompt).with(prompt, attachments: [ { type: "file", path: "/shared-tmp/dummy.txt" } ])
    expect(Turbo::StreamsChannel).to receive(:broadcast_replace_to).at_least(:once)
    called = []
    allow(Time).to receive(:current) { called << Time.now; called.size == 1 ? Time.now : Time.now + 1 }
    described_class.perform_now(session.id, prompt, file_paths, display_state)
  end

  it "deletes uploaded files after completion" do
    expect(File).to receive(:delete).with(Pathname.new("/tmp/dummy.txt"))
    described_class.perform_now(session.id, prompt, file_paths, display_state)
  end

  it "closes session after completion" do
    expect(session).to receive(:close_session)
    described_class.perform_now(session.id, prompt, file_paths, display_state)
  end

  it "handles no file_paths gracefully" do
    expect(session).to receive(:send_prompt).with(prompt, attachments: nil)
    expect { described_class.perform_now(session.id, prompt, nil, display_state) }.not_to raise_error
  end
end
