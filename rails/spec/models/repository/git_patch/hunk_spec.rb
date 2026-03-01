# frozen_string_literal: true

require "rails_helper"

RSpec.describe Repository::GitPatch::Hunk do
  let(:hunk_text) do
    <<~HUNK
      @@ -1,3 +1,4 @@
       some context line
      -old line
      +new line
       other context line
    HUNK
  end

  let(:hunk) do
    described_class.new.parse(hunk_text)
  end

  describe "#drop_if" do
    it "converts dropped '-' lines to context, removes dropped '+' lines, and adjusts header.to_length" do
      original_to_length = hunk.header.to_length

      # keep only the '+' line (index 2)
      hunk.drop_if do |l|
        l.index != 2
      end

      prefixes = hunk.lines.map(&:prefix)
      expect(prefixes).to include("+")
      expect(prefixes).not_to include("-")

      # One '-' line was converted to context, so to_length should increase by 1
      expect(hunk.header.to_length).to eq(original_to_length + 1)

      # lines count should remain the same (converted, not removed)
      expect(hunk.lines.size).to eq(4)
    end
  end

  describe "#reduce_context" do
    it "removes extra leading and trailing context lines beyond the specified size and updates header ranges" do
      original_from_line = hunk.header.from_line
      original_from_length = hunk.header.from_length
      original_to_line = hunk.header.to_line
      original_to_length = hunk.header.to_length

      # reduce to 0 context lines around diffs
      hunk.reduce_context(0)

      # Leading context (1 line) and trailing context (1 line) should be removed
      expect(hunk.lines.first.prefix).not_to eq(" ")
      expect(hunk.lines.last.prefix).not_to eq(" ")

      expect(hunk.header.from_line).to eq(original_from_line + 1)
      expect(hunk.header.to_line).to eq(original_to_line + 1)

      expect(hunk.header.from_length).to eq(original_from_length - 2)
      expect(hunk.header.to_length).to eq(original_to_length - 2)
    end
  end

  describe "#reverse" do
    it "swaps +/- prefixes and swaps header line numbers and lengths" do
      orig_from_line = hunk.header.from_line
      orig_to_line = hunk.header.to_line
      orig_from_length = hunk.header.from_length
      orig_to_length = hunk.header.to_length

      orig_prefixes = hunk.lines.map(&:prefix)

      hunk.reverse

      new_prefixes = hunk.lines.map(&:prefix)

      # '-' becomes '+', '+' becomes '-', ' ' stays
      expect(new_prefixes).to eq(orig_prefixes.map { |p|
        if p == "-"
          "+"
        else
          p == "+" ? "-" : p
        end
      })

      # header ranges swapped
      expect(hunk.header.from_line).to eq(orig_to_line)
      expect(hunk.header.to_line).to eq(orig_from_line)
      expect(hunk.header.from_length).to eq(orig_to_length)
      expect(hunk.header.to_length).to eq(orig_from_length)
    end
  end
end
