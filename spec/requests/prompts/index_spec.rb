# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /prompts" do
  it "renders the index view with all prompts" do
    prompt1 = Prompt.new(text: "Prompt 1")
    prompt2 = Prompt.new(text: "Prompt 2")
    allow(Prompt).to receive(:all).and_return([prompt1, prompt2])

    get prompts_path

    expect(controller).to be_a(PromptsController)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Prompt 1")
    expect(response.body).to include("Prompt 2")
    expect(response.body).to include("Show this prompt")
    expect(response.body).to include("New prompt")
  end
end
