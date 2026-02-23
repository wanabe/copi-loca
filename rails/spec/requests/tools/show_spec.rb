require 'rails_helper'

RSpec.describe "GET /tools/:id", type: :request do
  let!(:tool) { Tool.create!(name: "Test Tool", description: "A tool for testing") }

  it "renders a successful response" do
    get tool_url(tool)
    expect(response).to be_successful
    expect(response.body).to include(tool.name)
  end
end
