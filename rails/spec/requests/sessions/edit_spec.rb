# frozen_string_literal: true

require "rails_helper"

describe "GET /sessions/:id/edit" do
  let(:session) { Session.create!(id: SecureRandom.uuid, model: "gpt-4.1") }

  it "renders the edit session page (200)" do
    get "/sessions/#{session.id}/edit"
    expect(response).to have_http_status(:ok)
  end

  context "with custom agents and tools" do
    before do
      session.custom_agents.create!(name: "Agent Smith", description: "A test agent")
      tool = Tool.create!(name: "Test Tool", description: "A tool for testing", tool_parameters: [
        ToolParameter.new(name: "param1", description: "First parameter"),
        ToolParameter.new(name: "param2", description: "Second parameter")
      ])
      session.tools << tool
    end

    it "displays custom agents and tools" do
      get "/sessions/#{session.id}/edit"
      expect(response.body).to include("Agent Smith")
      expect(response.body).to include("Test Tool")
    end
  end
end
