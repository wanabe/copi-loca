# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /prompts/:id" do
  it "renders the show view for the prompt" do
    prompt = Prompt.new(id: 1, text: "Test prompt")
    allow(prompt).to receive_messages(response: nil, persisted?: true)
    allow(Prompt).to receive(:find).with(1).and_return(prompt)

    get prompt_path(1)

    expect(controller).to be_a(PromptsController)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Test prompt")
    expect(response.body).to include("Edit this prompt")
    expect(response.body).to include("Back to prompts")
    expect(response.body).to include("Run this prompt")
    expect(response.body).to include("Destroy this prompt")
  end
end
