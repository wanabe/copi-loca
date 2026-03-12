# frozen_string_literal: true

require "rails_helper"

RSpec.describe Components::Prompts::Prompt do
  let(:prompt) { Prompt.new(id: 42, text: "Sample prompt text") }
  let(:response) { Response.new(text: "Sample response text") }

  context "when prompt has no response" do
    it "renders prompt id and text, but not response" do
      allow(prompt).to receive(:response).and_return(nil)
      rendered = render described_class.new(prompt: prompt)
      expect(rendered).to include("<h2>42</h2>")
      expect(rendered).to match(%r{<p[^>]*>Sample prompt text</p>})
      expect(rendered).not_to include("Response")
    end
  end

  context "when prompt has a response" do
    it "renders prompt id, text, and response" do
      allow(prompt).to receive(:response).and_return(response)
      rendered = render described_class.new(prompt: prompt)
      expect(rendered).to include("<h2>42</h2>")
      expect(rendered).to match(%r{<p[^>]*>Sample prompt text</p>})
      expect(rendered).to include("<h3>Response</h3>")
      expect(rendered).to match(%r{<p[^>]*>Sample response text</p>})
    end
  end
end
