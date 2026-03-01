# frozen_string_literal: true

require "rails_helper"

describe "POST /changes/execute_revert", type: :request do
  it "redirects to root with notice" do
    session_double = double(send: nil, idle?: true)
    copilot_client = instance_double(Copilot::Client)
    allow(Client).to receive(:instance).and_return(instance_double(Client, copilot_client: copilot_client))
    allow(copilot_client).to receive(:create_session).and_yield(session_double)
    allow(copilot_client).to receive(:wait).and_yield
    post "/changes/execute_revert"
    expect(response).to redirect_to(root_path)
    follow_redirect!
    expect(response.body).to include("Code changes reverted.")
  end
end
