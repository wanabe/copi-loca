# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Git::Entries::ShowBlob do
  subject(:rendered) { render described_class.new(ref: ref, content: content, path: path) }

  let(:ref) { "main" }
  let(:path) { "README.md" }

  context "when content is valid UTF-8" do
    let(:content) { "Hello, world!" }

    it "renders the blob title and content" do
      expect(rendered).to include("Blob main:README.md")
      expect(rendered).to include("Hello, world!")
    end
  end

  context "when content is not valid UTF-8" do
    let(:content) { "\xFF\xD8".b.force_encoding("ASCII-8BIT") }

    it "renders a binary file warning" do
      expect(rendered).to include("Binary file (cannot display content)")
    end
  end
end
