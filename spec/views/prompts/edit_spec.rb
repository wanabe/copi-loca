# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Prompts::Edit do
  subject(:rendered) { render described_class.new(prompt: prompt) }

  let(:prompt) { Prompt.new(id: 1) }

  describe "#view_template" do
    it "renders the edit prompt view with correct title and links" do
      expect(rendered).to match(%r{<h1[^>]*>Editing prompt</h1>})
      expect(rendered).to include("action=\"/prompts/#{prompt.id}\"")
      expect(rendered).to include("Show this prompt")
      expect(rendered).to include("Back to prompts")
    end
  end
end
