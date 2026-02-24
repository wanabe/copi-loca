require 'rails_helper'

describe "POST /changes/execute_revert", type: :request do
  it "redirects to root with notice" do
    session_double = double(send: nil, idle?: true)
    copilot_client = double()
    allow(Client).to receive_message_chain(:instance, :copilot_client).and_return(copilot_client)
    allow(copilot_client).to receive(:create_session).and_yield(session_double)
    allow(copilot_client).to receive(:wait) { |&block| block.call(session_double) }
    post "/changes/execute_revert"
    expect(response).to redirect_to(root_path)
    follow_redirect!
    expect(response.body).to include("Code changes reverted.")
  end
end
