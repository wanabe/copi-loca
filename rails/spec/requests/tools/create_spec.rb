# frozen_string_literal: true

require "rails_helper"

RSpec.describe "POST /tools" do
  let(:valid_attributes) { { name: "Test Tool", description: "A tool for testing", parameters: "{}" } }
  let(:invalid_attributes) { { name: nil, description: nil, parameters: nil } }

  context "with valid parameters" do
    it "creates a new Tool" do
      expect do
        post tools_url, params: { tool: valid_attributes }
      end.to change(Tool, :count).by(1)
    end

    it "redirects to the created tool" do
      post tools_url, params: { tool: valid_attributes }
      expect(response).to redirect_to(tool_url(Tool.last))
    end
  end

  context "with invalid parameters" do
    it "does not create a new Tool" do
      expect do
        post tools_url, params: { tool: invalid_attributes }
      end.not_to change(Tool, :count)
    end

    it "renders a response with 422 status (i.e. to display the 'new' template)" do
      post tools_url, params: { tool: invalid_attributes }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
