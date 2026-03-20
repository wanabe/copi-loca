# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /git/grep" do
  it "renders the git grep view with no pattern" do
    get git_grep_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Git")
  end

  it "renders the git grep view with a pattern" do
    get git_grep_path, params: { pattern: "test" }
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("test")
  end

  it "renders the git grep view with a pattern and files" do
    get git_grep_path, params: { pattern: "test", files: "file1.rb\nfile2.rb" }
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("test")
    expect(response.body).to include("file1.rb")
    expect(response.body).to include("file2.rb")
  end
end
