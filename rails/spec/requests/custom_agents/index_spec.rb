# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /custom_agents", type: :request do
  let!(:custom_agent) { CustomAgent.create!(name: "Test Agent", description: "A custom agent for testing") }

  it "renders a successful response" do
    get custom_agents_url
    expect(response).to be_successful
    expect(response.body).to include(custom_agent.name)
  end
end
