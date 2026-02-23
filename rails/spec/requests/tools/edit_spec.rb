require 'rails_helper'

RSpec.describe "GET /tools/:id/edit", type: :request do
  let!(:tool) { Tool.create!(name: "Test Tool", description: "A tool for testing") }

  it "renders a successful response" do
    get edit_tool_url(tool)
    expect(response).to be_successful
  end
end
