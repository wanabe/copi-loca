require 'rails_helper'

RSpec.describe "PATCH /operations/:id", type: :request do
  let!(:operation) { Operation.create!(command: "echo hello", directory: "/tmp", execution_timing: :manual) }
  let(:new_attributes) { { command: "echo world", directory: "/home", execution_timing: :background } }
  let(:invalid_attributes) { { command: nil, directory: nil, execution_timing: nil } }

  context "with valid parameters" do
    it "updates the requested operation" do
      patch operation_url(operation), params: { operation: new_attributes }
      operation.reload
      expect(operation.command).to eq("echo world")
      expect(operation.directory).to eq("/home")
      expect(operation.execution_timing).to eq("background")
    end

    it "redirects to the operation" do
      patch operation_url(operation), params: { operation: new_attributes }
      operation.reload
      expect(response).to redirect_to(operation_url(operation))
    end
  end

  context "with invalid parameters" do
    it "renders a response with 422 status (i.e. to display the 'edit' template)" do
      patch operation_url(operation), params: { operation: invalid_attributes }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
