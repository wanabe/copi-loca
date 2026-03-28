# frozen_string_literal: true

require "rails_helper"

RSpec.describe Components::Layout do
  subject(:rendered) { render described_class.new(title: title, view: Views::Base.new) {} }

  context "with title" do
    let(:title) { "Test Title" }

    it "renders the layout with the given title" do
      expect(rendered).to include("<title>Test Title</title>")
      expect(rendered).to include("<meta name=\"viewport\" content=\"width=device-width,initial-scale=1\">")
      expect(rendered).to include("Copi Loca")
      expect(rendered).to include("<link rel=\"stylesheet\"")
      expect(rendered).to include("<script type=\"importmap\"")
    end
  end

  context "without title" do
    let(:title) { nil }

    it "renders the layout with default title if none given" do
      expect(rendered).to include("<title>Copi Loca</title>")
    end
  end
end
