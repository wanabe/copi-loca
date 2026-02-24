require 'rails_helper'

describe "GET /changes/:id", type: :request do
  it "returns 200 and renders the show page for a real commit" do
  commit = Repository.log(1).first
  get "/changes/#{commit[:hash]}"
  expect(response).to have_http_status(:ok)
  expect(response.body).to include("Commit")
end
end
