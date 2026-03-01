# frozen_string_literal: true

require "rails_helper"

describe "GET /changes" do
  it "returns 200 and renders the index page" do
    get "/changes"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Changes")
  end
end
