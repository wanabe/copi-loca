# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'POST /prompts/:id/run' do
  let(:prompt) { Prompt.new(id: 1, text: 'Test prompt') }

  before do
    allow(Prompt).to receive(:find).with('1').and_return(prompt)
    allow(prompt).to receive(:run).and_return(true)
  end

  it 'runs the prompt and redirects to show with notice' do
    post run_prompt_path(prompt)

    expect(controller).to be_a(PromptsController)
    expect(response).to redirect_to(prompt_path(prompt))
    follow_redirect!
    expect(response.body).to include('Prompt was successfully run.')
  end

  it 'responds with JSON when requested' do
    post run_prompt_path(prompt), as: :json

    expect(response).to have_http_status(:ok)
    expect(response.content_type).to include('application/json')
  end
end
