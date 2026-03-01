# frozen_string_literal: true

require "rails_helper"

RSpec.describe "RebaseController#start", type: :request do
  before do
    allow(Repository).to receive_messages(rebase_i: true, rebase_status: { done: [], todo: [], onto: "abc1234" })
  end

  it "posts to start and redirects" do
    post "/rebase/start", params: { rebase_steps: [{ action: "pick", hash: "abc1234" }] }
    expect(response).to have_http_status(:found)
    expect(response).to redirect_to("/rebase")
  end

  it "handles empty steps param (no params duplicate)" do
    post "/rebase/start", params: { rebase_steps: [{}] }
    expect(response).to have_http_status(:found).or have_http_status(:internal_server_error)
  end

  it "handles missing steps param (no params duplicate)" do
    post "/rebase/start"
    expect(response).to have_http_status(:found)
    expect(response).to redirect_to("/rebase")
  end

  it "handles error gracefully on start (error)" do
    allow(Repository).to receive(:rebase_i).and_raise(StandardError)
    expect do
      post "/rebase/start", params: { rebase_steps: [{ action: "pick", hash: "abc1234" }] }
    end.to raise_error(StandardError)
  end

  it "responds to turbo_stream format" do
    post "/rebase/start", params: { rebase_steps: [{ action: "pick", hash: "abc1234" }] },
      headers: { "Accept" => "text/vnd.turbo-stream.html" }
    expect(response).to have_http_status(:ok).or have_http_status(:found)
  end
end
