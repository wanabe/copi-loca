# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PATCH /custom_agents/:id" do
  let!(:custom_agent) { CustomAgent.create!(name: "Test Agent", description: "A custom agent for testing") }
  let(:new_attributes) { { name: "Updated Agent", description: "Updated description" } }
  let(:invalid_attributes) { { name: nil, description: nil } }

  context "with valid parameters" do
    it "updates the requested custom_agent" do
      patch custom_agent_url(custom_agent), params: { custom_agent: new_attributes }
      custom_agent.reload
      expect(custom_agent.name).to eq("Updated Agent")
      expect(custom_agent.description).to eq("Updated description")
    end

    it "redirects to the custom_agent" do
      patch custom_agent_url(custom_agent), params: { custom_agent: new_attributes }
      custom_agent.reload
      expect(response).to redirect_to(custom_agent_url(custom_agent))
    end
  end

  context "with invalid parameters" do
    it "renders a response with 422 status" do
      patch custom_agent_url(custom_agent), params: { custom_agent: invalid_attributes }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
