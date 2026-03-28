# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /git/refs/HEAD/-/edit" do
  it "renders the edit view with commit message and diffs" do
    log = double(commits: [double(message: "Commit msg")])
    allow(Git::Log).to receive(:new).with(ref: "HEAD").and_return(double(run: log))
    allow(Git::LsFiles).to receive(:new).and_return(double(run: double(entries: [])))
    allow(Git::Diff).to receive(:new).and_return(double(run: double(patches: [])))
    get edit_git_head_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Git HEAD amend")
    expect(response.body).to include("Unstaged")
    expect(response.body).to include("Staged")
  end

  it "handles missing commit message gracefully" do
    log = double(commits: [])
    allow(Git::Log).to receive(:new).with(ref: "HEAD").and_return(double(run: log))
    allow(Git::LsFiles).to receive(:new).and_return(double(run: double(entries: [])))
    allow(Git::Diff).to receive(:new).and_return(double(run: double(patches: [])))
    get edit_git_head_path
    expect(response).to have_http_status(:ok)
    # Should not error if commit message is missing
  end

  it "renders with untracked and unstaged files and diffs" do
    log = double(commits: [double(message: "Commit msg")])
    untracked_entries = [double(path: "untracked.txt")]
    unstaged_patch = double(header: double(src_path: "unstaged.txt"), type: :modify, render: "diff content")
    staged_patch = double(header: double(dst_path: "staged.txt"), type: :modify, render: "diff content")
    allow(Git::Log).to receive(:new).with(ref: "HEAD").and_return(double(run: log))
    allow(Git::LsFiles).to receive(:new).and_return(double(run: double(entries: untracked_entries)))
    allow(File).to receive(:read).with("untracked.txt").and_return("untracked content")
    allow(Git::Diff).to receive(:new).with(no_args).and_return(double(run: double(patches: [unstaged_patch])))
    allow(Git::Diff).to receive(:new).with(dst_ref: "HEAD~", cached: true).and_return(double(run: double(patches: [staged_patch])))
    get edit_git_head_path
    expect(response).to have_http_status(:ok)
    # The file names should appear in the HTML as summary elements
    expect(response.body).to include('<span class="text-sm text-gray-600">untracked.txt</span>')
    expect(response.body).to include('<span class="text-sm text-gray-600">unstaged.txt</span>')
    expect(response.body).to include('<span class="text-sm text-gray-600">staged.txt</span>')
    # The untracked file content should be rendered
    expect(response.body).to include("untracked content")
  end
end
