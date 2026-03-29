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
  let(:header_double) { instance_double(Git::Diff::Header, src_path: "file1.txt", dst_path: "file1.txt", render: "diff --git a/file1.txt b/file1.txt\n--- a/file1.txt\n+++ b/file1.txt\n") }
  let(:hunk_double) { instance_double(Git::Diff::Hunk, render: "diff content") }
  let(:patch_double) { instance_double(Git::Diff::Patch, type: :modify, header: header_double, hunks: [hunk_double]) }
  let(:unstaged_diff_map) { { "file1.txt" => patch_double } }
  let(:staged_header_double) { instance_double(Git::Diff::Header, src_path: "file3.txt", dst_path: "file3.txt", render: "diff --git a/file3.txt b/file3.txt\n--- a/file3.txt\n+++ b/file3.txt\n") }
  let(:staged_hunk_double) { instance_double(Git::Diff::Hunk, render: "staged diff") }
  let(:staged_patch_double) { instance_double(Git::Diff::Patch, type: :delete, header: staged_header_double, hunks: [staged_hunk_double]) }
  let(:staged_diff_map) { { "file3.txt" => staged_patch_double } }
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
