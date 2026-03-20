# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /git" do
  it "renders the git index view" do
    get git_root_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Git") # Adjust as needed for actual content
  end
end
