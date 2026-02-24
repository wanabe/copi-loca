require 'rails_helper'

describe "GET /changes/uncommitted", type: :request do
  it "renders the uncommitted page (200)" do
    allow(Repository).to receive(:staged_diffs).and_return([])
    allow(Repository).to receive(:unstaged_diffs).and_return([])
    get "/changes/uncommitted"
    expect(response).to have_http_status(:ok)
  end

  it "renders with staged_file_path param" do
    allow(Repository).to receive(:staged_diffs).and_return([ [ "foo.txt", "diff" ] ])
    allow(Repository).to receive(:unstaged_diffs).and_return([])
    get "/changes/uncommitted", params: { staged_file_path: "foo.txt" }
    expect(response).to have_http_status(:ok)
  end

  it "renders with unstaged_file_path param" do
    allow(Repository).to receive(:staged_diffs).and_return([])
    allow(Repository).to receive(:unstaged_diffs).and_return([ [ "bar.txt", "diff" ] ])
    get "/changes/uncommitted", params: { unstaged_file_path: "bar.txt" }
    expect(response).to have_http_status(:ok)
  end
end
