# frozen_string_literal: true

require "rails_helper"

describe Git::Diff do
  describe "#initialize" do
    it "sets default values" do
      instance = described_class.new
      expect(instance.patches).to eq([])
    end
  end

  describe "#command" do
    it "returns the correct git command" do
      expect(described_class.new.command).to eq("diff")
    end
  end

  describe "#run" do
    it "calls Git.call with correct args for cached" do
      instance = described_class.new(src_ref: "main", dst_ref: "feature", cached: true)
      allow(Git).to receive(:call).and_return("")
      instance.run
      expect(Git).to have_received(:call).with("diff", "--cached", "main..feature")
    end

    it "calls Git.call with correct args for non-cached" do
      instance = described_class.new(src_ref: "main", dst_ref: "feature", cached: false)
      allow(Git).to receive(:call).and_return("")
      instance.run
      expect(Git).to have_received(:call).with("diff", "main..feature")
    end

    it "calls Git.call with correct args when dst_ref and src_ref are nil" do
      instance = described_class.new(cached: false)
      allow(Git).to receive(:call).and_return("")
      instance.run
      expect(Git).to have_received(:call).with("diff")
    end

    it "calls Git.call with correct args when paths are provided" do
      instance = described_class.new(src_ref: "main", dst_ref: "feature", cached: false, paths: ["file1.txt", "file2.txt"])
      allow(Git).to receive(:call).and_return("")
      instance.run
      expect(Git).to have_received(:call).with("diff", "main..feature", "--", "file1.txt", "file2.txt")
    end
  end

  describe "#parse" do
    it "parses the diff output into patches" do
      diff_output = <<~DIFF
        diff --git a/file1.txt b/file1.txt
        new file mode 100644
        index 0000000..e69de29 100644
        diff --git a/file2.txt b/file2.txt
        deleted file mode 100644
        index e69de29..0000000
        diff --git a/file3.txt b/file3.txt
        index e69de29..e69de29
        --- a/file3.txt
        +++ b/file3.txt
        @@ -0,0 +1,2 @@ some content
        +line 1
        +line 2
        diff --git a/file4.txt b/file4.txt
        old mode 100644
        new mode 100755
        index e69de29..e69de29
        diff --git a/old_name.txt b/new_name.txt
        similarity index 100%
        rename from old_name.txt
        rename to new_name.txt
      DIFF
      instance = described_class.new
      instance.parse(diff_output)
      expect(instance.patches.map(&:type)).to eq(%i[new delete modify modify modify])
      expect(instance.patches[2].hunks.size).to eq(1)
      expect(instance.patches[2].hunks[0].lines.size).to eq(2)
      expect(instance.patches[2].hunks[0].lines[0].content).to eq("line 1")
      expect(instance.patches[2].hunks[0].lines[0].type).to eq(:+)
      expect(instance.patches[2].hunks[0].lines[1].content).to eq("line 2")
      expect(instance.patches[2].hunks[0].lines[1].type).to eq(:+)
      expect(instance.patches[3].header.old_mode).to eq("100644")
      expect(instance.patches[3].header.new_mode).to eq("100755")
      expect(instance.patches[4].header.src_path).to eq("old_name.txt")
      expect(instance.patches[4].header.has_similarity).to be true
      expect(instance.patches[4].header.similarity_index).to eq(100)
      expect(instance.patches[4].header.rename_from).to eq("old_name.txt")
      expect(instance.patches[4].header.rename_to).to eq("new_name.txt")
    end
  end

  describe Git::Diff::Patch do
    describe "#initialize" do
      it "sets default values" do
        instance = described_class.new
        expect(instance.hunks).to eq([])
      end
    end

    describe "#type" do
      let(:header) { Git::Diff::Header.new(has_new_file: true) }
      let(:patch) { described_class.new(header: header) }

      it "returns :new if has_new_file" do
        expect(patch.type).to eq(:new)
      end

      it "returns :delete if has_deleted_mode" do
        patch.header.has_new_file = false
        patch.header.has_deleted_mode = true
        expect(patch.type).to eq(:delete)
      end

      it "returns :modify otherwise" do
        patch.header.has_new_file = false
        patch.header.has_deleted_mode = false
        expect(patch.type).to eq(:modify)
      end
    end
  end

  describe Git::Diff::Hunk do
    describe "#initialize" do
      it "sets default values" do
        instance = described_class.new
        expect(instance.lines).to eq([])
        expect(instance.has_src_range_end).to be false
        expect(instance.has_dst_range_end).to be false
      end
    end

    describe "#src_range_end=" do
      it "sets has_src_range_end when src_range_end= is called" do
        hunk = described_class.new
        hunk.src_range_end = 5
        expect(hunk.has_src_range_end).to be true
      end
    end

    describe "#dst_range_end=" do
      it "sets has_dst_range_end when dst_range_end= is called" do
        hunk = described_class.new
        hunk.dst_range_end = 10
        expect(hunk.has_dst_range_end).to be true
      end
    end
  end

  describe Git::Diff::Hunk::Line do
    it "has type and content attributes" do
      line = described_class.new(type: "-", content: "removed line")
      expect(line.type).to eq("-")
      expect(line.content).to eq("removed line")
    end
  end
end
