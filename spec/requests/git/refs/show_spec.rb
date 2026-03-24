# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /git/refs/*ref" do
  it "renders the ref show page successfully" do
    ref = "main"
    get "/git/refs/#{ref}"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Git Ref: #{ref}")
    expect(response.body).to include("Grep")
    expect(response.body).to include("Entries")
  end
end
