require 'rails_helper'

RSpec.describe RunOperationJob, type: :job do
  let(:operation) { Operation.create!(command: 'echo hello', directory: '/tmp', execution_timing: :background) }

  before do
    allow(Operation).to receive(:find).with(operation.id).and_return(operation)
    now = Time.current
    allow(Time).to receive(:current) do
      now += 0.2
      now
    end
    allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)
  end

  describe '#perform' do
    context 'when operation runs and yields output' do
      it 'broadcasts output and status' do
        # Use a stub for run, not expect(...).to receive
        def operation.run
          yield StringIO.new("hello\n")
          0
        end
        described_class.perform_now(operation.id)
        # Check that broadcast_replace_to was called with expected args
        expect(Turbo::StreamsChannel).to have_received(:broadcast_replace_to).with(
          operation,
          target: "operation-result",
          partial: "operations/run",
          locals: hash_including(operation: operation, output: "", status: "running")
        ).once
        expect(Turbo::StreamsChannel).to have_received(:broadcast_replace_to).with(
          operation,
          target: "operation-result",
          partial: "operations/run",
          locals: hash_including(operation: operation, output: "hello\n", status: 0)
        ).once
      end
    end
  end
end
