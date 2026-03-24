# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Git::Commits::Index do
  subject(:rendered) { render described_class.new(ref: ref, commits: commits) }

  let(:ref) { "main" }
  let(:commit) do
    instance_double(
      Git::Log::Commit,
      message: "Initial commit",
      commit_hash: "abc123",
      author_name: "Alice",
      author_email: "alice@example.com",
      author_date: "2022-01-01 12:00:00",
      committer_date: "2022-01-01 12:05:00"
    )
  end
  let(:commits) { Kaminari.paginate_array([commit]).page(1).per(5) }

  it "renders the commit list with correct details" do
    expect(rendered).to include("Git Commits on main")
    expect(rendered).to include("Initial commit")
    expect(rendered).to include("Commit Hash: abc123")
    expect(rendered).to include(ERB::Util.html_escape("Author: Alice <alice@example.com>"))
    expect(rendered).to include("Author Date: 2022-01-01 12:00:00")
    expect(rendered).to include("Commit Date: 2022-01-01 12:05:00")
  end
end
