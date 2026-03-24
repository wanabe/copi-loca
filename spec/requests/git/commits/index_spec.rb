# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /git/refs/:ref/-/commits" do
  let(:ref) { "main" }
  let(:commits) do
    [
      instance_double(
        Git::Log::Commit,
        commit_hash: "abc123",
        author_name: "Alice",
        author_email: "alice@example.com",
        author_date: Time.zone.parse("2023-01-01T12:00:00Z"),
        committer_date: Time.zone.parse("2023-01-01T12:05:00Z"),
        message: "Initial commit"
      )
    ]
  end

  before do
    log = instance_double(Git::Log, run: double(commits: commits))
    allow(Git::Log).to receive(:new).with(ref: ref).and_return(log)
    allow(Kaminari).to receive(:paginate_array).and_call_original
  end

  it "renders the commits index view with commit details" do
    get "/git/refs/#{ref}/-/commits"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Git Commits on #{ref}")
    expect(response.body).to include("Initial commit")
    expect(response.body).to include("abc123")
    expect(response.body).to include("Alice")
    expect(response.body).to include("alice@example.com")
    expect(response.body).to include("2023-01-01 12:00:00 UTC")
    expect(response.body).to include("2023-01-01 12:05:00 UTC")
  end
end
