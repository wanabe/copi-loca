# frozen_string_literal: true

require "rails_helper"

RSpec.describe "POST /prompts" do
  let(:valid_params) { { prompt: { id: 1, text: "Test prompt" } } }
  let(:invalid_params) { { prompt: { id: nil, text: "" } } }

  before do
    allow(File).to receive(:write).and_return(true)
  end

  describe "with valid params" do
    it "creates a new prompt and redirects to show" do
      post "/prompts", params: valid_params
      expect(response).to redirect_to(prompt_path(1))
      follow_redirect!
      expect(response.body).to include("Prompt was successfully created.")
      expect(File).to have_received(:write).with(Rails.root.join("docs/prompts/1/prompt.md").to_s, "Test prompt")
    end
  end

  describe "with invalid params" do
    it "renders new with unprocessable status" do
      post "/prompts", params: invalid_params
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("error")
      expect(File).not_to have_received(:write)
    end
  end
end
