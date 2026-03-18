# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Memos::Index do
  subject(:rendered) { render described_class.new }

  describe "#view_template" do
    it "renders the memo index view with correct title and form" do
      expect(rendered).to match(%r{<h1[^>]*>Memo</h1>})
      expect(rendered).to include("id=\"memo_input\"")
      expect(rendered).to include("Add")
      expect(rendered).to include("memo#saveMemo")
      expect(rendered).to include("memo#deleteMemo")
    end
  end
end
