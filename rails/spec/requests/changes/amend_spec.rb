# frozen_string_literal: true

require "rails_helper"

describe "GET /changes/amend" do
  it "renders the amend page (200)" do
    allow(Repository).to receive_messages(amend_diffs: [], unstaged_diffs: [], head_commit_message: "")
    get "/changes/amend"
    expect(response).to have_http_status(:ok)
  end

  it "renders with staged_file_path param" do
    allow(Repository).to receive_messages(amend_diffs: [["foo.txt", "diff"]], unstaged_diffs: [],
      head_commit_message: "")
    get "/changes/amend", params: { staged_file_path: "foo.txt" }
    expect(response).to have_http_status(:ok)
  end

  it "renders with unstaged_file_path param" do
    allow(Repository).to receive_messages(amend_diffs: [], unstaged_diffs: [["bar.txt", "diff"]],
      head_commit_message: "")
    get "/changes/amend", params: { unstaged_file_path: "bar.txt" }
    expect(response).to have_http_status(:ok)
  end
end
