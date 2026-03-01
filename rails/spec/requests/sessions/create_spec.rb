# frozen_string_literal: true

require "rails_helper"

describe "POST /sessions", type: :request do
  it "creates a session and redirects to show", :with_auth do
    post "/sessions", params: { session: { model: "gpt-4.1" } }
    new_session = Session.order(:created_at).last
    expect(response).to redirect_to(session_path(new_session.id))
    follow_redirect!
    expect(response.body).to include("gpt-4.1")
  end

  it "returns unprocessable entity for invalid model", :with_auth do
    allow(Client).to receive(:available_models).and_return([{ id: "gpt-4.1", billing: { multiplier: 1 } }])
    post "/sessions", params: { session: { model: "" } }
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include(ERB::Util.h("Model can't be blank"))
  end
end
