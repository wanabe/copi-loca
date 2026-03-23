# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Git::Grep::Show do
  subject(:rendered) do
    render described_class.new(
      branches: branches,
      pattern: pattern,
      files: files,
      branch: branch,
      ignore_case: ignore_case,
      grep: grep
    )
  end

  let(:branches) { %w[main dev] }
  let(:pattern) { "TODO" }
  let(:files) { "file1.rb\nfile2.rb" }
  let(:branch) { "main" }
  let(:ignore_case) { true }
  let(:grep) do
    Git::Grep.new(
      pattern: pattern,
      branch: branch,
      chunks: [
        Git::Grep::Chunk.new(
          path: "file1.rb",
          lines: [
            Git::Grep::Line.new(content: "TODO something")
          ]
        ),
        Git::Grep::Chunk.new(
          path: "file2.rb",
          lines: [
            Git::Grep::Line.new(content: "TODO another")
          ]
        )
      ]
    )
  end

  it "renders the Git Grep form and results" do
    expect(rendered).to include("Git Grep")
    expect(rendered).to include("Branch:")
    expect(rendered).to include("Pattern:")
    expect(rendered).to include("Files:")
    expect(rendered).to include("Grep")
    expect(rendered).to include("Results:")
    expect(rendered).to include("file1.rb")
    expect(rendered).to include("TODO something")
    expect(rendered).to include("file2.rb")
    expect(rendered).to include("TODO another")
  end

  context "without branch" do
    let(:branch) { "" }

    it "renders file links" do
      expect(rendered).to include("href=\"#{file_path(grep.chunks[0].path, raw: false)}\"")
      expect(rendered).to include("href=\"#{file_path(grep.chunks[1].path, raw: false)}\"")
    end
  end
end
