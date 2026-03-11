# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Prompts::Show do
  subject(:rendered) { render described_class.new(prompt: prompt) }

  let(:prompt) { Prompt.new(id: 1, text: "Prompt content") }

  describe "#view_template" do
    it "renders the show prompt view with correct title and content" do
      expect(rendered).to include(prompt.text)
      expect(rendered).to include("Edit this prompt")
      expect(rendered).to include("Back to prompts")
    end
  end
end
