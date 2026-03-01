# frozen_string_literal: true

require "rails_helper"

RSpec.describe Repository::GitPatch::NoHeader do
  let(:hunks_text) do
    <<~HUNKS
      @@ -1,3 +1,4 @@
       some context line
      -old line
      +new line
       other context line
      @@ -5,1 +6,1 @@
       some other line
    HUNKS
  end

  let(:no_header_patch) do
    described_class.new.parse(hunks_text)
  end

  describe "#diff_line_at" do
    it "returns the correct line for a given diff line number" do
      # diff line numbers are 1-origin and include hunk headers
      expect(no_header_patch.diff_line_at(2).content).to eq("some context line")
      expect(no_header_patch.diff_line_at(3).content).to eq("old line")
      expect(no_header_patch.diff_line_at(4).content).to eq("new line")
      expect(no_header_patch.diff_line_at(5).content).to eq("other context line")
      expect(no_header_patch.diff_line_at(7).content).to eq("some other line")
    end

    it "returns nil for out-of-range line numbers" do
      expect(no_header_patch.diff_line_at(0)).to be_nil
      expect(no_header_patch.diff_line_at(8)).to be_nil
    end

    it "returns nil for hunk header lines" do
      expect(no_header_patch.diff_line_at(1)).to be_nil
      expect(no_header_patch.diff_line_at(6)).to be_nil
    end
  end
end
