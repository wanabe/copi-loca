require 'rails_helper'

describe "GET /changes/:id", type: :request do
  it "returns 200 and renders the show page for a real commit" do
    commit = Repository.log(1).first
    get "/changes/#{commit[:hash]}"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Commit")
  end

  it "renders the show page with file_path param" do
    commit = Repository.log(1).first
    file_diffs = Repository.tracked_diffs(commit[:hash])
    file_path = file_diffs.first&.first
    skip "No file diffs for commit" unless file_path
    get "/changes/#{commit[:hash]}", params: { file_path: file_path }
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(file_path)
  end
end
