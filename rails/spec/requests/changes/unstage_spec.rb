# frozen_string_literal: true

require "rails_helper"

describe "POST /changes/unstage" do
  it "redirects to uncommitted_changes_path after unstaging" do
    allow(Repository).to receive(:unstage_file)
    post "/changes/unstage", params: { file_path: "foo.txt" }
    expect(response).to redirect_to(uncommitted_changes_path(unstaged_file_path: "foo.txt"))
    expect(Repository).to have_received(:unstage_file).with("foo.txt", amend: false)
  end

  it "redirects to amend_changes_path if amend param is present" do
    allow(Repository).to receive(:unstage_file)
    post "/changes/unstage", params: { file_path: "foo.txt", amend: "1" }
    expect(response).to redirect_to(amend_changes_path(unstaged_file_path: "foo.txt"))
    expect(Repository).to have_received(:unstage_file).with("foo.txt", amend: true)
  end

  it "redirects to uncommitted_changes_path if line_number is present" do
    allow(Repository).to receive(:unstage_line)
    post "/changes/unstage", params: { file_path: "foo.txt", line_number: "42" }
    expect(response).to redirect_to(uncommitted_changes_path(staged_file_path: "foo.txt"))
    expect(Repository).to have_received(:unstage_line).with("foo.txt", 42, amend: false)
  end

  it "redirects to amend_changes_path if line_number and amend params are present" do
    allow(Repository).to receive(:unstage_line)
    post "/changes/unstage", params: { file_path: "foo.txt", line_number: "42", amend: "1" }
    expect(response).to redirect_to(amend_changes_path(staged_file_path: "foo.txt"))
    expect(Repository).to have_received(:unstage_line).with("foo.txt", 42, amend: true)
  end

  it "redirects to uncommitted_changes_path if file_path is missing" do
    post "/changes/unstage"
    expect(response).to redirect_to(uncommitted_changes_path(unstaged_file_path: nil))
  end

  it "redirects to amend_changes_path if file_path is missing and amend param is present" do
    post "/changes/unstage", params: { amend: "1" }
    expect(response).to redirect_to(amend_changes_path(unstaged_file_path: nil))
  end
end
