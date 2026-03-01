# frozen_string_literal: true

require "rails_helper"

describe "GET /sessions/new" do
  it "renders the new session page (200)" do
    allow(Client).to receive(:available_models).and_return([{ id: "gpt-4.1", billing: { multiplier: 1 } }])
    get "/sessions/new"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("gpt-4.1")
  end
end
