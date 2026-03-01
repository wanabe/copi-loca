# frozen_string_literal: true

require "rails_helper"

RSpec.describe "DELETE /tools/:id" do
  let!(:tool) { Tool.create!(name: "Test Tool", description: "A tool for testing") }

  it "destroys the requested tool" do
    expect do
      delete tool_url(tool)
    end.to change(Tool, :count).by(-1)
  end

  it "redirects to the tools list" do
    delete tool_url(tool)
    expect(response).to redirect_to(tools_url)
  end
end
