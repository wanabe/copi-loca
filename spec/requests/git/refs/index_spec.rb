# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /git/refs" do
  it "renders the refs index successfully" do
    allow(Git).to receive(:call).with("branch", "--format=%(refname:short)").and_return("main\ndevelop\n")
    allow(Git).to receive(:call).with("branch", "-r", "--format=%(refname:short)").and_return("origin/main\norigin/develop\n")

    get "/git/refs"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("HEAD")
    expect(response.body).to include("main")
    expect(response.body).to include("develop")
    expect(response.body).to include("origin/main")
    expect(response.body).to include("origin/develop")
  end
end
