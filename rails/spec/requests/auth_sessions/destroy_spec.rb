require 'rails_helper'

describe "DELETE /auth_sessions/:id", type: :request do
  it "logs out and redirects to root" do
    # ログイン状態をセット
    delete "/auth_sessions/1"
    expect(response).to redirect_to(root_path)
    follow_redirect!
    expect(response.body).to include("Logged out.")
  end
end
