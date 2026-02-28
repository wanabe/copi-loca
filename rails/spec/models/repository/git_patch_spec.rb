# frozen_string_literal: true

require "rails_helper"

RSpec.describe Repository::GitPatch do
  context "with header" do
    let(:text) do
      <<~DIFF
        diff --git a/foo.rb b/foo.rb
        index 1234567..89abcde 100644
        --- a/foo.rb
        +++ b/foo.rb
        @@ -1,3 +1,4 @@
         some context line
        -old line
        +new line
         other context line
      DIFF
    end

    it "parses a git diff into structure and serializes back to the original text" do
      patch = described_class.new

      expect { patch.parse(text) }.not_to raise_error

      # structural expectations
      expect(patch.header).to be_a(described_class::FileHeader)
      expect(patch.hunks).to be_an(Array)
      expect(patch.hunks.size).to eq(1)
      hunk = patch.hunks.first
      expect(hunk).to be_a(described_class::Hunk)
      expect(hunk.header).to be_a(described_class::HunkHeader)
      expect(hunk.header.from_line).to eq(1)
      expect(hunk.header.from_length).to eq(3)
      expect(hunk.header.to_line).to eq(1)
      expect(hunk.header.to_length).to eq(4)
      expect(hunk.lines.size).to eq(4)
      expect(hunk.lines[0].content).to eq("some context line")
      expect(hunk.lines[1].content).to eq("old line")
      expect(hunk.lines[2].content).to eq("new line")
      expect(hunk.lines[3].content).to eq("other context line")

      # round-trip
      expect(patch.to_s).to eq(text)
    end
  end

  context "without header" do
    let(:text) do
      <<~DIFF
        @@ -1,3 +1,4 @@ some context line
         some context line
        -old line
        +new line
        +added line
         other context line
        @@ -5,1 +6,1 @@
         some other line
      DIFF
    end

    it "parses a git diff without header into structure and serializes back to the original text" do
      patch = described_class::NoHeader.new

      expect { patch.parse(text) }.not_to raise_error

      # structural expectations
      expect(patch.hunks).to be_an(Array)
      expect(patch.hunks.size).to eq(2)
      expect(patch.hunks[0].header.from_line).to eq(1)
      expect(patch.hunks[0].header.from_length).to eq(3)
      expect(patch.hunks[0].header.to_line).to eq(1)
      expect(patch.hunks[0].header.to_length).to eq(4)
      expect(patch.hunks[0].header.context).to eq("some context line")

      # round-trip
      expect(patch.to_s).to eq(text)
    end
  end
end
