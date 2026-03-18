# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /memos" do
  it "renders the index view" do
    get "/memos"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Memo") # Adjust as needed for actual content
  end
end
