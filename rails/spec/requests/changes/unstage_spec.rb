# frozen_string_literal: true

require "rails_helper"

describe "POST /changes/unstage", type: :request do
  it "redirects to uncommitted_changes_path after unstaging" do
    allow(Repository).to receive(:unstage_file)
    post "/changes/unstage", params: { file_path: "foo.txt" }
    expect(response).to redirect_to(uncommitted_changes_path(unstaged_file_path: "foo.txt"))
  end

  it "redirects to amend_changes_path if amend param is present" do
    allow(Repository).to receive(:unstage_file)
    post "/changes/unstage", params: { file_path: "foo.txt", amend: "1" }
    expect(response).to redirect_to(amend_changes_path(unstaged_file_path: "foo.txt"))
  end

  it "redirects to uncommitted_changes_path if file_path is missing" do
    post "/changes/unstage"
    expect(response).to redirect_to(uncommitted_changes_path(unstaged_file_path: nil))
  end
end
