# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Prompts::Index do
  let(:prompts) { [Prompt.new(id: 1), Prompt.new(id: 2)] }

  context "with notice" do
    subject(:rendered) { render described_class.new(prompts: prompts, notice: "Test notice") }

    it "renders the notice" do
      expect(rendered).to include("Test notice")
      expect(rendered).to include('style="color: green"')
    end
  end

  context "without notice" do
    subject(:rendered) { render described_class.new(prompts: prompts) }

    it "renders the Prompts title" do
      expect(rendered).to include("<h1>Prompts</h1>")
    end

    it "renders each prompt with show link" do
      prompts.each do |prompt|
        expect(rendered).to include("/prompts/#{prompt.id}")
        expect(rendered).to include("Show this prompt")
      end
    end

    it "renders the New prompt link" do
      expect(rendered).to include("/prompts/new")
      expect(rendered).to include("New prompt")
    end
  end
end
