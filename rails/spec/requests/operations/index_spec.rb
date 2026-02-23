require 'rails_helper'

RSpec.describe "GET /operations", type: :request do
  let!(:operation) { Operation.create!(command: "echo hello", directory: "/tmp", execution_timing: :manual) }

  it "renders a successful response" do
    get operations_url
    expect(response).to be_successful
    expect(response.body).to include(operation.command)
    expect(response.body).to include(operation.directory)
    expect(response.body).to include(operation.execution_timing.titleize)
  end
end
