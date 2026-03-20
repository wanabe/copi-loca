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
      grep_result: grep_result
    )
  end

  let(:branches) { %w[main dev] }
  let(:pattern) { "TODO" }
  let(:files) { "file1.rb\nfile2.rb" }
  let(:branch) { "main" }
  let(:ignore_case) { true }
  let(:grep_result) { "file1.rb:1: TODO something\nfile2.rb:2: TODO another" }

  it "renders the Git Grep form and results" do
    expect(rendered).to include("Git Grep")
    expect(rendered).to include("Branch:")
    expect(rendered).to include("Pattern:")
    expect(rendered).to include("Files:")
    expect(rendered).to include("Grep")
    expect(rendered).to include(grep_result)
  end
end
