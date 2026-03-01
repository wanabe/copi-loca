# frozen_string_literal: true

require "rails_helper"

RSpec.describe "POST /operations", type: :request do
  let(:valid_attributes) { { command: "echo hello", directory: "/tmp", execution_timing: :manual } }
  let(:invalid_attributes) { { command: nil, directory: nil, execution_timing: nil } }

  context "with valid parameters" do
    it "creates a new Operation" do
      expect do
        post operations_url, params: { operation: valid_attributes }
      end.to change(Operation, :count).by(1)
    end

    it "redirects to the created operation" do
      post operations_url, params: { operation: valid_attributes }
      expect(response).to redirect_to(operation_url(Operation.last))
    end
  end

  context "with invalid parameters" do
    it "does not create a new Operation" do
      expect do
        post operations_url, params: { operation: invalid_attributes }
      end.not_to change(Operation, :count)
    end

    it "renders a response with 422 status (i.e. to display the 'new' template)" do
      post operations_url, params: { operation: invalid_attributes }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
