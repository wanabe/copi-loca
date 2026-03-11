# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /prompts/new" do
  it "renders the new view with a new prompt" do
    allow(Prompt).to receive(:max_id).and_return(42)
    allow(Prompt).to receive(:new).and_call_original

    get new_prompt_path

    expect(controller).to be_a(PromptsController)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("New prompt")
    expect(response.body).to include('id="prompt_id"')
    expect(Prompt).to have_received(:new).with(id: 43)
  end
end
