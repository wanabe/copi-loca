# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Prompts::New do
  subject(:rendered) { render described_class.new(prompt: prompt) }

  let(:prompt) { Prompt.new }

  describe "#view_template" do
    it "renders the new prompt view with correct title and form" do
      expect(rendered).to match(%r{<h1[^>]*>New prompt</h1>})
      expect(rendered).to include("Back to prompts")
      expect(rendered).to include("form")
    end
  end
end
