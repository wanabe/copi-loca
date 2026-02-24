require 'rails_helper'

describe "POST /auth_sessions", type: :request do
  before do
    stub_const("ENV", ENV.to_hash.merge("COPI_ADMIN_PASSWORD" => "testpass"))
  end

  it "logs in with correct password" do
    post "/auth_sessions", params: { password: "testpass" }
    expect(response).to redirect_to(root_path)
    follow_redirect!
    expect(response.body).to include("Logged in successfully.")
  end

  it "shows error with wrong password" do
    post "/auth_sessions", params: { password: "wrong" }
    expect(response.body).to include("Invalid password.")
    expect(response.body).to include("Login")
  end
end
