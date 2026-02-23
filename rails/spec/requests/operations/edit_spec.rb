require 'rails_helper'

RSpec.describe "GET /operations/:id/edit", type: :request do
  let!(:operation) { Operation.create!(command: "echo hello", directory: "/tmp", execution_timing: :manual) }

  it "renders a successful response" do
    get edit_operation_url(operation)
    expect(response).to be_successful
  end
end
