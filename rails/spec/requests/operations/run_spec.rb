require 'rails_helper'

RSpec.describe "POST /operations/:id/run", type: :request do
  let(:operation) { Operation.create!(command: "echo hello", directory: "/tmp", execution_timing: :background) }

  context "when execution_timing is :background" do
    it "enqueues RunOperationJob and renders partial" do
      expect(RunOperationJob).to receive(:perform_later).with(operation.id)
      post run_operation_url(operation)
      expect(response).to be_successful
      expect(response.body).to include("run")
    end
  end

  context "when execution_timing is not :background" do
    let(:operation) { Operation.create!(command: "echo hello", directory: "/tmp", execution_timing: :manual) }
    it "executes operation and renders partial with output and status" do
      post run_operation_url(operation)
      expect(response).to be_successful
      expect(response.body).to include("hello")
    end
  end
end
