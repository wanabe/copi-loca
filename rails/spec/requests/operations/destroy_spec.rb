# frozen_string_literal: true

require "rails_helper"

RSpec.describe "DELETE /operations/:id", type: :request do
  let!(:operation) { Operation.create!(command: "echo hello", directory: "/tmp", execution_timing: :manual) }

  it "destroys the requested operation" do
    expect do
      delete operation_url(operation)
    end.to change(Operation, :count).by(-1)
  end

  it "redirects to the operations list" do
    delete operation_url(operation)
    expect(response).to redirect_to(operations_url)
  end
end
