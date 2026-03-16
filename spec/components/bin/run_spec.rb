# frozen_string_literal: true

require "rails_helper"

RSpec.describe Components::Bin::Run do
  subject(:rendered) { render described_class.new(status: status, output: output) }

  let(:status) { "Success" }
  let(:output) { "Output text" }

  describe "#view_template" do
    it "renders the run status and output when both are present" do
      expect(rendered).to include("Run status")
      expect(rendered).to include(status)
      expect(rendered).to include("Run result")
      expect(rendered).to include(output)
    end

    it "renders only status if output is nil" do
      expect(render(described_class.new(status: status, output: nil))).to include("Run status")
      expect(render(described_class.new(status: status, output: nil))).to include(status)
      expect(render(described_class.new(status: status, output: nil))).not_to include("Run result")
    end

    it "renders only output if status is nil" do
      expect(render(described_class.new(status: nil, output: output))).to include("Run result")
      expect(render(described_class.new(status: nil, output: output))).to include(output)
      expect(render(described_class.new(status: nil, output: output))).not_to include("Run status")
    end
  end
end
