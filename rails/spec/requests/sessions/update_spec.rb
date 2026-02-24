require 'rails_helper'

RSpec.describe "PATCH /sessions/:id", type: :request do
  let!(:session) { Session.create!(id: SecureRandom.uuid, model: "gpt-4.1") }

  it "updates session and redirects to show", :with_auth do
    patch "/sessions/#{session.id}", params: { session: { model: "gpt-5.1" } }
    expect(response).to redirect_to(session_path(session.id))
    follow_redirect!
    expect(response.body).to include("gpt-5.1")
    expect(session.reload.model).to eq("gpt-5.1")
  end

  it "returns unprocessable entity for invalid model", :with_auth do
    patch "/sessions/#{session.id}", params: { session: { model: "" } }
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include(ERB::Util.h("Model can't be blank"))
  end
end
