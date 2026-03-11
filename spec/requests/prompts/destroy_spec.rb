# frozen_string_literal: true

require "rails_helper"

RSpec.describe "DELETE /prompts/:id" do
  let(:prompt) { Prompt.new(id: 1, text: "Delete me") }

  before do
    allow(File).to receive(:delete).and_return(true)
  end

  it "deletes the prompt and redirects" do
    allow(Prompt).to receive(:find).with("1").and_return(prompt)
    delete prompt_path(prompt)
    expect(response).to redirect_to(prompts_path)
    follow_redirect!
    expect(response.body).to include("Prompt was successfully destroyed.")
    expect(File).to have_received(:delete).with(Rails.root.join(".github/prompts/1.prompt.md").to_s)
  end

  it "returns not found for missing prompt" do
    allow(Prompt).to receive(:find).with("-1").and_raise(ActiveRecord::RecordNotFound)
    delete prompt_path(-1)
    expect(response).to have_http_status(:not_found)
    expect(File).not_to have_received(:delete)
  end
end
