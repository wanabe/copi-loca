require 'rails_helper'

RSpec.describe "PATCH /tools/:id", type: :request do
  let!(:tool) { Tool.create!(name: "Test Tool", description: "A tool for testing") }
  let(:new_attributes) { { name: "Updated Tool", description: "Updated description" } }
  let(:invalid_attributes) { { name: nil, description: nil, parameters: nil } }

  context "with valid parameters" do
    it "updates the requested tool" do
      patch tool_url(tool), params: { tool: new_attributes }
      tool.reload
      expect(tool.name).to eq("Updated Tool")
      expect(tool.description).to eq("Updated description")
    end

    it "redirects to the tool" do
      patch tool_url(tool), params: { tool: new_attributes }
      tool.reload
      expect(response).to redirect_to(tool_url(tool))
    end
  end

  context "with invalid parameters" do
    it "renders a response with 422 status (i.e. to display the 'edit' template)" do
      patch tool_url(tool), params: { tool: invalid_attributes }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
