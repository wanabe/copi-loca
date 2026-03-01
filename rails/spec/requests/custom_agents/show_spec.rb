# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /custom_agents/:id", type: :request do
  let!(:custom_agent) { CustomAgent.create!(name: "Test Agent", description: "A custom agent for testing") }

  it "renders a successful response" do
    get custom_agent_url(custom_agent)
    expect(response).to be_successful
    expect(response.body).to include(custom_agent.name)
  end
end
