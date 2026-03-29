# frozen_string_literal: true

require "rails_helper"

describe "POST /git/refs/HEAD/-/unstage_line" do
  let(:hunk) do
    <<~HUNK
      @@ -1,6 +1,6 @@
       keep line 1
       keep line 2
      -old line 1
      -old line 2
      +new line 1
      +new line 2
       keep line 3
       keep line 4
    HUNK
  end

  it "redirects to new_git_head_path by default" do
    allow(Git).to receive(:call).and_yield(StringIO.new).and_return("Applied patch")
    post unstage_line_git_head_path, params: { path: "foo.rb", hunk: hunk, lineno: 1 }
    expect(response).to redirect_to(new_git_head_path(open: "foo.rb"))
  end

  it "redirects to edit_git_head_path if for=edit" do
    allow(Git).to receive(:call).and_yield(StringIO.new).and_return("Applied patch")
    post unstage_line_git_head_path, params: { path: "foo.rb", hunk: hunk, lineno: 1, for: "edit" }
    expect(response).to redirect_to(edit_git_head_path(open: "foo.rb"))
  end
end
