# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'PATCH /prompts/:id' do
  let(:prompt) { Prompt.new(id: 1, text: 'Original text') }
  let(:valid_params) { { prompt: { text: 'Updated text' } } }
  let(:invalid_params) { { prompt: { text: '' } } }

  before do
    allow(File).to receive(:write).and_return(true)
    allow(Prompt).to receive(:find).with('1').and_return(prompt)
  end

  context 'with valid params' do
    it 'updates the prompt and redirects' do
      patch prompt_path(prompt), params: valid_params

      expect(response).to redirect_to(prompt_path(prompt))
      follow_redirect!
      expect(response.body).to include('Prompt was successfully updated.')
      expect(response.body).to include('Updated text')
      expect(prompt.text).to eq('Updated text')
      expect(File).to have_received(:write).with(Rails.root.join('.github/prompts/1.prompt.md').to_s, 'Updated text')
    end

    it 'returns JSON with updated prompt' do
      patch prompt_path(prompt), params: valid_params, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Updated text')
      expect(prompt.text).to eq('Updated text')
      expect(File).to have_received(:write).with(Rails.root.join('.github/prompts/1.prompt.md').to_s, 'Updated text')
    end
  end

  context 'with invalid params' do
    it 'renders errors if update fails' do
      patch prompt_path(prompt), params: invalid_params

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(ERB::Util.html_escape("can't be blank"))
      expect(File).not_to have_received(:write)
    end

    it 'returns JSON errors if update fails' do
      patch prompt_path(prompt), params: invalid_params, as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("can't be blank")
      expect(File).not_to have_received(:write)
    end
  end
end
