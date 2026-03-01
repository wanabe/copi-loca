# frozen_string_literal: true

require "rails_helper"

RSpec.describe "RebaseController#continue" do
  before do
    allow(Repository).to receive_messages(rebase_status: { done: [], todo: [], onto: "abc1234" }, log_for_rebase: [])
  end

  it "posts to continue and redirects on success" do
    allow(RebaseController).to receive(:new).and_wrap_original do |method, *args|
      instance = method.call(*args)
      allow(instance).to receive(:system).with("git rebase --continue").and_return(true)
      instance
    end
    post "/rebase/continue"
    expect(response).to have_http_status(:found)
    expect(response).to redirect_to("/rebase")
    follow_redirect!
    expect(response.body).to include("Rebase continued.")
  end

  it "posts to continue and redirects on failure" do
    allow(RebaseController).to receive(:new).and_wrap_original do |method, *args|
      instance = method.call(*args)
      allow(instance).to receive(:system).with("git rebase --continue").and_return(false)
      instance
    end
    post "/rebase/continue"
    expect(response).to have_http_status(:found)
    expect(response).to redirect_to("/rebase")
    follow_redirect!
    expect(response.body).to include("Rebase continue failed.")
  end
end
