# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /operations/:id", type: :request do
  let!(:operation) { Operation.create!(command: "echo hello", directory: "/tmp", execution_timing: :manual) }

  it "renders a successful response" do
    get operation_url(operation)
    expect(response).to be_successful
    expect(response.body).to include(operation.command)
    expect(response.body).to include(operation.directory)
    expect(response.body).to include(operation.execution_timing.titleize)
  end

  context "when the operation is :immediate" do
    let!(:operation) { Operation.create!(command: "ls", directory: "/tmp", execution_timing: :immediate) }

    before do
      allow(Operation).to receive(:find).and_return(operation)
      allow(operation).to receive(:run).and_return(["foo.rb\nbar.rb\n", 0])
    end

    it "renders a successful response with command result" do
      get operation_url(operation)
      expect(response).to be_successful
      expect(response.body).to include(operation.command)
      expect(response.body).to include(operation.directory)
      expect(response.body).to include(operation.execution_timing.titleize)
      expect(response.body).to include("foo.rb")
      expect(response.body).to include("bar.rb")
    end
  end
end
