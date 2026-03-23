# frozen_string_literal: true

require "rails_helper"

RSpec.describe Git::Grep do
  describe "#run" do
    let(:pattern) { "test" }
    let(:branch) { "main" }
    let(:files) { "file1.rb\nfile2.rb" }
    let(:ignore_case) { true }

    it "parses git grep output correctly" do
      git_grep = described_class.new(pattern: pattern, branch: branch, files: files, ignore_case: ignore_case)
      allow(Git).to receive(:call).and_return(<<~OUTPUT)
        main:file1.rb:This is a test line in file1.
        main:file1.rb:Another test line in file1.
        main:file2.rb:And a test line in file2.
      OUTPUT
      git_grep.run
      expect(Git).to have_received(:call).with("grep", "-i", pattern, branch, "--", "file1.rb", "file2.rb")
      expect(git_grep.chunks.size).to eq(2)
      expect(git_grep.chunks[0].lines.size).to eq(2)
      expect(git_grep.chunks[0].lines[0].path).to eq("file1.rb")
      expect(git_grep.chunks[0].lines[0].content).to eq("This is a test line in file1.")
      expect(git_grep.chunks[0].lines[1].path).to eq("file1.rb")
      expect(git_grep.chunks[0].lines[1].content).to eq("Another test line in file1.")
      expect(git_grep.chunks[1].lines.size).to eq(1)
      expect(git_grep.chunks[1].lines[0].path).to eq("file2.rb")
      expect(git_grep.chunks[1].lines[0].content).to eq("And a test line in file2.")
    end

    it "parses git grep output correctly when branch is blank" do
      git_grep = described_class.new(pattern: pattern, branch: nil, files: files, ignore_case: ignore_case)
      allow(Git).to receive(:call).and_return(<<~OUTPUT)
        file1.rb:This is a test line in file1.
        file2.rb:This is a test line in file2.
        file2.rb:Another test line in file2.
      OUTPUT
      git_grep.run
      expect(Git).to have_received(:call).with("grep", "-i", pattern, "--", "file1.rb", "file2.rb")
      expect(git_grep.chunks.size).to eq(2)
      expect(git_grep.chunks[0].lines.size).to eq(1)
      expect(git_grep.chunks[0].lines[0].path).to eq("file1.rb")
      expect(git_grep.chunks[0].lines[0].content).to eq("This is a test line in file1.")
      expect(git_grep.chunks[1].lines.size).to eq(2)
      expect(git_grep.chunks[1].lines[0].path).to eq("file2.rb")
      expect(git_grep.chunks[1].lines[0].content).to eq("This is a test line in file2.")
      expect(git_grep.chunks[1].lines[1].path).to eq("file2.rb")
      expect(git_grep.chunks[1].lines[1].content).to eq("Another test line in file2.")
    end
  end
end
