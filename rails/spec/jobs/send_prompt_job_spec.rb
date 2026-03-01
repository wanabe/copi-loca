# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendPromptJob, type: :job do
  let(:session) { instance_double(Session, id: "session1") }
  let(:prompt) { "test prompt" }
  let(:file_paths) { ["/shared-tmp/dummy.txt"] }
  let(:display_state) { { show_messages: true } }

  before do
    allow(Session).to receive(:find).and_return(session)
    allow(session).to receive(:wait_until_idle).and_yield(:rpc_message)
    allow(session).to receive_messages(send_prompt: :message, reload: session)
    allow(session).to receive(:close_session)
    allow(File).to receive(:exist?).and_return(true)
    allow(File).to receive(:delete)
    allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)
    allow(Time).to receive(:current).and_return(Time.zone.now)
    allow(described_class).to receive(:new).and_wrap_original do |original_method, *args|
      job = original_method.call(*args)
      allow(job).to receive(:sleep)
      job
    end
  end

  it "calls send_prompt and broadcasts running/idle, including delayed re-render" do
    called = []
    allow(Time).to receive(:current) {
      called << Time.zone.now
      called.size == 1 ? Time.zone.now : Time.zone.now + 1
    }
    described_class.perform_now(session.id, prompt, file_paths, display_state)
    expect(session).to have_received(:send_prompt).with(prompt, attachments: [{ type: "file", path: "/shared-tmp/dummy.txt" }])
    expect(Turbo::StreamsChannel).to have_received(:broadcast_replace_to).at_least(:once)
  end

  it "deletes uploaded files after completion" do
    allow(FileUtils).to receive(:rm_f).with(Rails.root.join("tmp/dummy.txt"))
    described_class.perform_now(session.id, prompt, file_paths, display_state)
    expect(FileUtils).to have_received(:rm_f).with(Rails.root.join("tmp/dummy.txt"))
  end

  it "closes session after completion" do
    described_class.perform_now(session.id, prompt, file_paths, display_state)
    expect(session).to have_received(:close_session)
  end

  it "handles no file_paths gracefully" do
    expect { described_class.perform_now(session.id, prompt, nil, display_state) }.not_to raise_error
    expect(session).to have_received(:send_prompt).with(prompt, attachments: nil)
  end
end
