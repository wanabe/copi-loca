# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /tools/:id/edit" do
  let!(:tool) { Tool.create!(name: "Test Tool", description: "A tool for testing", tool_parameters: tool_parameters) }
  let(:tool_parameters) do
    [
      ToolParameter.new(name: "param1", description: "First parameter"),
      ToolParameter.new(name: "param2", description: "Second parameter")
    ]
  end

  it "renders a successful response" do
    get edit_tool_url(tool)
    expect(response).to be_successful
  end
end
