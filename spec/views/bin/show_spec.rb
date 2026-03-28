# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Bin::Show do
  subject(:rendered) { render described_class.new(bin: bin) }

  let(:bin) { Bin.new(id: "some_tool") }

  describe "#view_template" do
    it "renders the bin component" do
      expect(rendered).to include("Run this bin")
    end

    it "renders the run form with correct action" do
      expect(rendered).to include("action=\"/bin/some_tool/run\"")
      expect(rendered).to include("method=\"post\"")
    end

    it "renders the turbo frame tag" do
      expect(rendered).to include("bin-run-result")
    end

    it "renders the back link" do
      expect(rendered).to include("Back to bins")
    end
  end
end
