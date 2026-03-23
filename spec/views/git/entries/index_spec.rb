# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Git::Entries::Index do
  subject(:rendered) { render described_class.new(branches: branches) }

  context "when branches are present" do
    let(:branches) { ["main", "feature/with/slash"] }

    it "renders the title and all branch links" do
      expect(rendered).to include("Branches")
      expect(rendered).to include("main")
      expect(rendered).to include("feature/with/slash")
      expect(rendered).to match(%r{href="/git/entries/main"})
      expect(rendered).to match(%r{href="/git/entries/feature/with/slash"})
    end
  end

  context "when no branches are present" do
    let(:branches) { [] }

    it "renders a no branches found message" do
      expect(rendered).to include("No branches found")
    end
  end
end
