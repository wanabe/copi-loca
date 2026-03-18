# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /" do
  it "renders the home page successfully" do
    get "/"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Home")
    expect(response.body).to include("Bin")
    expect(response.body).to include("Files")
    expect(response.body).to include("Memos")
    expect(response.body).to include("Ps")
    expect(response.body).to include("Prompts")
  end
end
