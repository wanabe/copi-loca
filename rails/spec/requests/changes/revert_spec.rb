# frozen_string_literal: true

require "rails_helper"

describe "GET /changes/revert" do
  it "renders the revert page (200)" do
    get "/changes/revert"
    expect(response).to have_http_status(:ok)
  end
end
