require 'rails_helper'

RSpec.describe "RebaseController#continue", type: :request do
  before do
    allow(Repository).to receive(:rebase_status).and_return({ done: [], todo: [], onto: 'abc1234' })
    allow(Repository).to receive(:log_for_rebase).and_return([])
    allow_any_instance_of(Object).to receive(:system).and_return(true)
  end

  it "posts to continue and redirects on success" do
    post "/rebase/continue"
    expect(response).to have_http_status(:found)
    expect(response).to redirect_to("/rebase")
    follow_redirect!
    expect(response.body).to include("Rebase continued.")
  end

  it "posts to continue and redirects on failure" do
    allow_any_instance_of(Object).to receive(:system).and_return(false)
    post "/rebase/continue"
    expect(response).to have_http_status(:found)
    expect(response).to redirect_to("/rebase")
    follow_redirect!
    expect(response.body).to include("Rebase continue failed.")
  end
end
