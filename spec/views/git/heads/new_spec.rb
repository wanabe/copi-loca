# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Git::Heads::New do
  subject(:rendered) do
    render described_class.new(
      unstaged_files: unstaged_files,
      untracked_file_map: untracked_file_map,
      unstaged_diff_map: unstaged_diff_map,
      staged_diff_map: staged_diff_map
    )
  end

  let(:unstaged_files) { ["file1.txt", "file2.txt"] }
  let(:untracked_file_map) { { "file2.txt" => "new file content" } }

  let(:header_double) { instance_double(Git::Diff::Header, src_path: "file1.txt", dst_path: "file1.txt", render: "diff --git a/file1.txt b/file1.txt\n--- a/file1.txt\n+++ b/file1.txt\n") }
  let(:hunk_double) { instance_double(Git::Diff::Hunk, render: "diff content") }
  let(:patch_double) { instance_double(Git::Diff::Patch, type: :modify, header: header_double, hunks: [hunk_double]) }
  let(:unstaged_diff_map) { { "file1.txt" => patch_double } }

  let(:staged_header_double) { instance_double(Git::Diff::Header, src_path: "file3.txt", dst_path: "file3.txt", render: "diff --git a/file3.txt b/file3.txt\n--- a/file3.txt\n+++ b/file3.txt\n") }
  let(:staged_hunk_double) { instance_double(Git::Diff::Hunk, render: "deleted content") }
  let(:staged_patch_double) { instance_double(Git::Diff::Patch, type: :delete, header: staged_header_double, hunks: [staged_hunk_double]) }
  let(:staged_diff_map) { { "file3.txt" => staged_patch_double } }

  it "renders the Git dashboard with correct sections and file chunks" do
    expect(rendered).to include("<h1 class=\"text-2xl font-bold mb-4 flex items-center\"><span>Git HEAD status</span>")
    expect(rendered).to include("Unstaged")
    expect(rendered).to include("Staged")
    expect(rendered).to include("file1.txt")
    expect(rendered).to include("file2.txt")
    expect(rendered).to include("diff content")
    expect(rendered).to include("new file content")
    expect(rendered).to include("file3.txt")
    expect(rendered).to include("deleted content")
  end
end
