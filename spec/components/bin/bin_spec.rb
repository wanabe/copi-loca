# frozen_string_literal: true

require "rails_helper"

RSpec.describe Components::Bin::Bin, type: :component do
  subject(:rendered) { render described_class.new(bin: bin) }

  let(:bin) { instance_double(Bin, id: "test-bin", to_key: ["test-bin"], model_name: Bin.model_name) }

  describe "#view_template" do
    it "renders a div with the bin id as a heading" do
      expect(rendered).to include("<div")
      expect(rendered).to include("test-bin")
      expect(rendered).to include("<h2")
    end
  end
end
