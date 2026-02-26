require 'rails_helper'

RSpec.describe "RebaseController#index", type: :request do
  before do
    allow(Repository).to receive(:rebase_status).and_return({ done: [], todo: [], onto: 'abc1234' })
    allow(Repository).to receive(:log_for_rebase).and_return([])
  end

  it "renders index successfully" do
    get "/rebase"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Rebase")
  end

  it "index responds to turbo_stream format" do
    get "/rebase", headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
    expect(response).to have_http_status(:not_acceptable)
  end

  it "index responds to turbo_stream format (edge)" do
    get "/rebase", headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
    expect(response).to have_http_status(:not_acceptable)
  end

  it "handles empty log_for_rebase" do
    allow(Repository).to receive(:rebase_status).and_return(nil)
    allow(Repository).to receive(:log_for_rebase).and_return([])
    get "/rebase"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Rebase")
    expect(response.body.scan('<tbody>').size).to eq(1)
    expect(response.body.scan('<tr class=\"rebase__row\">').size).to eq(0)
    expect(response.body).to include("Start Rebase")
  end

  it "handles log_for_rebase with commits" do
    allow(Repository).to receive(:rebase_status).and_return({ done: [ { action: 'pick', hash: 'abc1234' } ], todo: [ { action: 'squash', hash: 'def4567' } ] })
    allow(Repository).to receive(:log_for_rebase).and_return([ { hash: 'abc1234', message: 'msg1' }, { hash: 'def4567', message: 'msg2' } ])

    get "/rebase"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("abc1234")
    expect(response.body).to include("def4567")
  end
end
