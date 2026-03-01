# frozen_string_literal: true

require "rails_helper"

describe "POST /changes/stage" do
  it "redirects to uncommitted_changes_path after staging" do
    allow(Repository).to receive(:stage_file)
    post "/changes/stage", params: { file_path: "foo.txt" }
    expect(response).to redirect_to(uncommitted_changes_path(staged_file_path: "foo.txt"))
    expect(Repository).to have_received(:stage_file).with("foo.txt")
  end

  it "redirects to amend_changes_path if amend param is present" do
    allow(Repository).to receive(:stage_file)
    post "/changes/stage", params: { file_path: "foo.txt", amend: "1" }
    expect(response).to redirect_to(amend_changes_path(staged_file_path: "foo.txt"))
    expect(Repository).to have_received(:stage_file).with("foo.txt")
  end

  it "redirects to uncommitted_changes_path if line_number is present" do
    allow(Repository).to receive(:stage_line)
    post "/changes/stage", params: { file_path: "foo.txt", line_number: "42" }
    expect(response).to redirect_to(uncommitted_changes_path(unstaged_file_path: "foo.txt"))
    expect(Repository).to have_received(:stage_line).with("foo.txt", 42)
  end

  it "redirects to amend_changes_path if line_number and amend params are present" do
    allow(Repository).to receive(:stage_line)
    post "/changes/stage", params: { file_path: "foo.txt", line_number: "42", amend: "1" }
    expect(response).to redirect_to(amend_changes_path(unstaged_file_path: "foo.txt"))
    expect(Repository).to have_received(:stage_line).with("foo.txt", 42)
  end

  it "redirects to uncommitted_changes_path if file_path is missing" do
    post "/changes/stage"
    expect(response).to redirect_to(uncommitted_changes_path(staged_file_path: nil))
  end

  it "redirects to amend_changes_path if file_path is missing and amend param is present" do
    post "/changes/stage", params: { amend: "1" }
    expect(response).to redirect_to(amend_changes_path(staged_file_path: nil))
  end
end
