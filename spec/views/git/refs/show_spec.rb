# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Git::Refs::Show do
  subject(:rendered) { render described_class.new(ref: ref) }

  let(:ref) { "main" }

  describe "#view_template" do
    it "renders the git ref title and links" do
      expect(rendered).to match(%r{<h1[^>]*>Git Ref: main</h1>})
      expect(rendered).to include("Grep")
      expect(rendered).to include("Entries")
      expect(rendered).to include(git_ref_grep_path(ref: ref))
      expect(rendered).to include(git_ref_entries_root_path(ref: ref))
    end
  end
end
