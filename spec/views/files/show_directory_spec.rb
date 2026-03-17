# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Files::ShowDirectory do
  subject(:rendered) { render described_class.new(entries: entries, path: path) }

  let(:path) { "/home/user" }
  let(:entries) do
    [
      ["directory", "docs"],
      ["file", "README.md"],
      ["unknown", "mystery"]
    ]
  end

  describe "#view_template" do
    it "renders the directory title and lists entries with correct icons and links" do
      expect(rendered).to include("Directory: #{path}")
      expect(rendered).to include("\u{1F4C1}") # folder icon
      expect(rendered).to include("docs")
      expect(rendered).to include("\u{1F4C4}") # file icon
      expect(rendered).to include("README.md")
      expect(rendered).to include("(raw)")
      expect(rendered).to include("\u{2753}") # unknown icon
      expect(rendered).to include("mystery")
    end
  end
end
