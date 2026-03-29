# frozen_string_literal: true

require "rails_helper"

describe "POST /git/refs/HEAD/-/stage_line" do
  it "redirects to new_git_head_path by default" do
    post "/git/refs/HEAD/-/stage_line", params: { path: "foo.rb", hunk: "h", lineno: 1 }
    expect(response).to redirect_to(new_git_head_path(open: "foo.rb"))
  end

  it "redirects to edit_git_head_path if for=edit" do
    post "/git/refs/HEAD/-/stage_line", params: { path: "foo.rb", hunk: "h", lineno: 1, for: "edit" }
    expect(response).to redirect_to(edit_git_head_path(open: "foo.rb"))
  end
end
