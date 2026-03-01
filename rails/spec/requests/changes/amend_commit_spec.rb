# frozen_string_literal: true

require "rails_helper"

describe "POST /changes/amend_commit" do
  it "redirects to uncommitted_changes_path after amend_commit" do
    allow(Repository).to receive(:amend_no_edit)
    allow(Repository).to receive(:amend_with_message)
    post "/changes/amend_commit", params: { no_edit: "1" }
    expect(response).to redirect_to(uncommitted_changes_path)
  end

  it "redirects to uncommitted_changes_path after amend_commit with commit_message param" do
    allow(Repository).to receive(:amend_no_edit)
    allow(Repository).to receive(:amend_with_message)
    post "/changes/amend_commit", params: { commit_message: "test message" }
    expect(response).to redirect_to(uncommitted_changes_path)
    expect(Repository).to have_received(:amend_with_message).with("test message", reset_author: false)
  end
end
