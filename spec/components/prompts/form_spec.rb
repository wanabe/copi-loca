# frozen_string_literal: true

require "rails_helper"

RSpec.describe Components::Prompts::Form do
  subject(:rendered) { render described_class.new(prompt: prompt) }

  let(:prompt) { Prompt.new(id: 1, text: "Sample prompt") }

  describe "#view_template" do
    it "renders the form with id and text fields" do
      expect(rendered).to include("form")
      expect(rendered).to include("id")
      expect(rendered).to include("text")
      expect(rendered).to include("submit")
    end

    it "displays errors when present" do
      prompt.errors.add(:text, "can't be blank")
      rendered_with_errors = render described_class.new(prompt: prompt)
      expect(rendered_with_errors).to include("prohibited this prompt from being saved")
      expect(rendered_with_errors).to include(ERB::Util.html_escape("can't be blank"))
    end
  end
end
