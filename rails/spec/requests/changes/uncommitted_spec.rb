# frozen_string_literal: true

require "rails_helper"

describe "GET /changes/uncommitted", type: :request do
  it "renders the uncommitted page (200)" do
    allow(Repository).to receive_messages(staged_diffs: [], unstaged_diffs: [])
    get "/changes/uncommitted"
    expect(response).to have_http_status(:ok)
  end

  it "renders with staged_file_path param" do
    allow(Repository).to receive_messages(staged_diffs: [["foo.txt", "diff"]], unstaged_diffs: [])
    get "/changes/uncommitted", params: { staged_file_path: "foo.txt" }
    expect(response).to have_http_status(:ok)
  end

  it "renders with unstaged_file_path param" do
    allow(Repository).to receive_messages(staged_diffs: [], unstaged_diffs: [["bar.txt", "diff"]])
    get "/changes/uncommitted", params: { unstaged_file_path: "bar.txt" }
    expect(response).to have_http_status(:ok)
  end
end
