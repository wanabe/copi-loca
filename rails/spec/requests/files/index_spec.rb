# frozen_string_literal: true

require "rails_helper"

describe "GET /files" do
  it "returns 200 and renders the index page" do
    get "/files"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Files")
  end
end
