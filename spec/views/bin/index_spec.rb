# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Bin::Index do
  subject(:rendered) { render described_class.new(bins: bins, notice: notice) }

  let(:bins) do
    Kaminari.paginate_array([
      instance_double(Bin, id: 1),
      instance_double(Bin, id: 2)
    ]).page(1).per(5)
  end
  let(:notice) { "Test notice" }

  describe "#view_template" do
    it "renders the notice if present" do
      expect(rendered).to include("Test notice")
    end

    it "renders the bins table with IDs" do
      expect(rendered).to include("Bins")
      bins.each do |bin|
        expect(rendered).to include(bin.id.to_s)
      end
    end
  end
end
