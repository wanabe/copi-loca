# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Git::Heads::Edit do
  subject(:rendered) do
    render described_class.new(
      unstaged_files: unstaged_files,
      untracked_file_map: untracked_file_map,
      unstaged_diff_map: unstaged_diff_map,
      staged_diff_map: staged_diff_map,
      commit_message: commit_message,
      flash: flash,
      breadcrumbs: breadcrumbs
    )
  end

  let(:unstaged_files) { ["file1.txt", "file2.txt"] }
  let(:untracked_file_map) { { "file2.txt" => "new content" } }
  let(:unstaged_diff_map) { { "file1.txt" => instance_double(Git::Diff::Patch, type: :modified, render: "diff content") } }
  let(:staged_diff_map) { { "file3.txt" => instance_double(Git::Diff::Patch, type: :added, render: "staged diff") } }
  let(:commit_message) { "Initial commit" }
  let(:flash) { { notice: "Test notice" } }
  let(:breadcrumbs) { [instance_double(Breadcrumb, name: "Crumb", link?: false, path: nil)] }

  it "renders the amend commit form with commit message" do
    expect(rendered).to include("Amend Commit")
    expect(rendered).to include(commit_message)
  end

  it "renders unstaged files with patch and new content" do
    expect(rendered).to include("diff content")
    expect(rendered).to include("new content")
  end

  it "renders nothing for unknown unstaged files" do
    expect do
      render described_class.new(
        unstaged_files: ["unknown.txt"],
        untracked_file_map: {},
        unstaged_diff_map: {},
        staged_diff_map: {},
        commit_message: "msg"
      )
    end.not_to raise_error
  end

  it "renders staged files" do
    expect(rendered).to include("staged diff")
  end

  it "renders file path in details" do
    expect(rendered).to include("file1.txt")
    expect(rendered).to include("file2.txt")
    expect(rendered).to include("file3.txt")
  end

  it "renders breadcrumbs and flash" do
    expect(rendered).to include("Test notice")
  end
end
