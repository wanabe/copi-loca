# frozen_string_literal: true

require "rails_helper"

RSpec.describe "DELETE /custom_agents/:id", type: :request do
  let!(:custom_agent) { CustomAgent.create!(name: "Test Agent", description: "A custom agent for testing") }

  it "destroys the requested custom_agent" do
    expect do
      delete custom_agent_url(custom_agent)
    end.to change(CustomAgent, :count).by(-1)
  end

  it "redirects to the custom_agents list" do
    delete custom_agent_url(custom_agent)
    expect(response).to redirect_to(custom_agents_url)
  end
end
