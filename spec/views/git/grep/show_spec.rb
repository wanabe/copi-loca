# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Git::Grep::Show do
  subject(:rendered) do
    render described_class.new(
      pattern: pattern,
      files: files,
      ref: ref,
      ignore_case: ignore_case,
      grep: grep
    )
  end

  let(:pattern) { "TODO" }
  let(:files) { "file1.rb\nfile2.rb" }
  let(:ref) { "main" }
  let(:ignore_case) { true }
  let(:grep) do
    Git::Grep.new(
      pattern: pattern,
      ref: ref,
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
    expect(rendered).to include(" on #{ref}")
    expect(rendered).to include("Pattern:")
    expect(rendered).to include("Files:")
    expect(rendered).to include("Grep")
    expect(rendered).to include("Results:")
    expect(rendered).to include("file1.rb")
    expect(rendered).to include("TODO something")
    expect(rendered).to include("file2.rb")
    expect(rendered).to include("TODO another")
  end
end
