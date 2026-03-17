# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Files::ShowFile do
  subject(:rendered) { render described_class.new(content: content, path: path) }

  let(:path) { "/some/file.txt" }

  describe "#view_template" do
    context "when content is valid encoding" do
      let(:content) { "Hello, world!" }

      it "renders the file view with correct title and content" do
        expect(rendered).to include("File: #{path}")
        expect(rendered).to include("<h1")
        expect(rendered).to include("Hello, world!")
      end
    end

    context "when content is not valid encoding" do
      let(:content) { "\xFF\xFE".dup.force_encoding("ASCII-8BIT") }

      it "renders a binary file warning" do
        expect(rendered).to include("Binary file (cannot display content)")
        expect(rendered).to include("File: #{path}")
      end
    end
  end
end
