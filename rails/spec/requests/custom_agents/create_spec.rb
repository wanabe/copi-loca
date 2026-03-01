# frozen_string_literal: true

require "rails_helper"

RSpec.describe "POST /custom_agents" do
  let(:valid_attributes) { { name: "Test Agent", description: "A custom agent for testing" } }
  let(:invalid_attributes) { { name: nil, description: nil } }

  context "with valid parameters" do
    it "creates a new CustomAgent" do
      expect do
        post custom_agents_url, params: { custom_agent: valid_attributes }
      end.to change(CustomAgent, :count).by(1)
    end

    it "redirects to the created custom_agent" do
      post custom_agents_url, params: { custom_agent: valid_attributes }
      expect(response).to redirect_to(custom_agent_url(CustomAgent.last))
    end
  end

  context "with invalid parameters" do
    it "does not create a new CustomAgent" do
      expect do
        post custom_agents_url, params: { custom_agent: invalid_attributes }
      end.not_to change(CustomAgent, :count)
    end

    it "renders a response with 422 status (i.e. to display the 'new' template)" do
      post custom_agents_url, params: { custom_agent: invalid_attributes }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
