# frozen_string_literal: true

require "rails_helper"

describe "GET /changes" do
  it "returns 200 and renders the index page" do
    get "/changes"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Changes")
  end

  context "when in rebasing" do
    before do
      allow(Repository).to receive(:rebase_status).and_return({ dir: "rebase-merge", head: "ref/heads/working-branch", onto: "base" })
    end

    it "returns 200 and renders the working branch" do
      get "/changes"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("working-branch")
    end
  end
end
