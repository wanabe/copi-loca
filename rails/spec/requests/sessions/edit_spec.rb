# frozen_string_literal: true

require "rails_helper"

describe "GET /sessions/:id/edit" do
  let(:session) { Session.create!(id: SecureRandom.uuid, model: "gpt-4.1") }

  it "renders the edit session page (200)" do
    get "/sessions/#{session.id}/edit"
    expect(response).to have_http_status(:ok)
  end
end
