require 'rails_helper'

describe "GET /changes/amend", type: :request do
  it "renders the amend page (200)" do
    allow(Repository).to receive(:amend_diffs).and_return([])
    allow(Repository).to receive(:unstaged_diffs).and_return([])
    allow(Repository).to receive(:head_commit_message).and_return("")
    get "/changes/amend"
    expect(response).to have_http_status(:ok)
  end

  it "renders with staged_file_path param" do
    allow(Repository).to receive(:amend_diffs).and_return([ [ "foo.txt", "diff" ] ])
    allow(Repository).to receive(:unstaged_diffs).and_return([])
    allow(Repository).to receive(:head_commit_message).and_return("")
    get "/changes/amend", params: { staged_file_path: "foo.txt" }
    expect(response).to have_http_status(:ok)
  end

  it "renders with unstaged_file_path param" do
    allow(Repository).to receive(:amend_diffs).and_return([])
    allow(Repository).to receive(:unstaged_diffs).and_return([ [ "bar.txt", "diff" ] ])
    allow(Repository).to receive(:head_commit_message).and_return("")
    get "/changes/amend", params: { unstaged_file_path: "bar.txt" }
    expect(response).to have_http_status(:ok)
  end
end
