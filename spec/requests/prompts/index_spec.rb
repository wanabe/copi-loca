# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /prompts" do
  it "renders the index view with all prompts" do
    prompt1 = instance_double(Prompt, id: 1, text: "Prompt 1", load: nil, name: nil, description: nil, response: nil)
    prompt2 = instance_double(Prompt, id: 2, text: "Prompt 2", load: nil, name: nil, description: nil, response: nil)
    allow(Prompt).to receive(:all).and_return([prompt1, prompt2])

    get prompts_path

    expect(controller).to be_a(PromptsController)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Prompt 1")
    expect(response.body).to include("Prompt 2")
    expect(response.body).to include("New prompt")
  end
end
