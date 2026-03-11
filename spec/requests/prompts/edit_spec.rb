# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GET /prompts/:id/edit' do
  let(:prompt) { Prompt.new(id: 42, text: 'Edit me') }

  before do
    allow(Prompt).to receive(:find).with('42').and_return(prompt)
    allow(prompt).to receive(:persisted?).and_return(true)
  end

  it 'renders the edit view for the prompt' do
    get edit_prompt_path(prompt)
    expect(controller).to be_a(PromptsController)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Editing prompt')
    expect(response.body).to include('Edit me')
    expect(response.body).to include('Show this prompt')
    expect(response.body).to include('Back to prompts')
    expect(response.body).to include("action=\"/prompts/#{prompt.id}\"")
  end
end
