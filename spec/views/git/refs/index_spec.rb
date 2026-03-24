# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Git::Refs::Index do
  subject(:rendered) { render described_class.new(refs: refs) }

  let(:refs) { %w[main develop feature-xyz] }

  describe "#view_template" do
    it "renders the title and a list of refs as links" do
      expect(rendered).to match(%r{<h1[^>]*>Git Refs</h1>})
      refs.each do |ref|
        expect(rendered).to include(ref)
        expect(rendered).to include(git_ref_path(ref: ref))
      end
    end
  end
end
