# frozen_string_literal: true

require "rails_helper"

describe "DELETE /sessions/:id" do
  let!(:session_obj) { Session.create!(id: SecureRandom.uuid, model: "gpt-4.1") }

  it "redirects to new_auth_session_path if not admin" do
    delete "/sessions/#{session_obj.id}"
    expect(response).to redirect_to(sessions_path)
  end
end
