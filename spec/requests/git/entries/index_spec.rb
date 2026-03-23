# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /git/entries" do
  it "renders the entries index view with branches" do
    allow(Git).to receive(:call).and_return(<<~LOCAL, <<~REMOTE)
      dev
    LOCAL
      origin/main
    REMOTE

    get "/git/entries"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("dev")
    expect(response.body).to include("origin/main")
  end
end
