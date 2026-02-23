require 'rails_helper'

RSpec.describe "GET /custom_agents/:id/edit", type: :request do
  let!(:custom_agent) { CustomAgent.create!(name: "Test Agent", description: "A custom agent for testing") }

  it "renders a successful response" do
    get edit_custom_agent_url(custom_agent)
    expect(response).to be_successful
  end
end
