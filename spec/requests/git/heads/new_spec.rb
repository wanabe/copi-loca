# frozen_string_literal: true

require "rails_helper"

describe "GET /git/heads/new" do
  it "renders the dashboard with unstaged and untracked files" do
    allow(Git).to receive(:call).with("ls-files", "--others", "--exclude-standard").and_return("untracked.txt\n")
    allow(File).to receive(:read).with("untracked.txt").and_return("untracked content")
    allow(Git).to receive(:call).with("diff").and_return(<<~DIFF)
      diff --git a/unstaged.txt b/unstaged.txt
      index e69de29..e69de29
      --- a/unstaged.txt
      +++ b/unstaged.txt
      @@ -2,1 +2,1 @@
       context
      +modified content
      -deleted content
       another line
    DIFF
    allow(Git).to receive(:call).with("diff", "--cached", "HEAD").and_return(<<~DIFF)
      diff --git a/staged.txt b/staged.txt
      index e69de29..e69de29
      --- a/staged.txt
      +++ b/staged.txt
      @@ -0,0 +1,2 @@
      +staged content
      diff --git a/deleted.txt b/deleted.txt
      deleted file mode 100644
      index e69de29..0000000
      diff --git a/added.txt b/added.txt
      new file mode 100644
      index 0000000..e69de29
      --- /dev/null
      +++ b/added.txt
      @@ -0,0 +1,2 @@
      +added content
    DIFF

    get new_git_head_path
    expect(response).to have_http_status(:ok)
    expect(controller).to be_a(Git::HeadsController)
    expect(response.body).to include("untracked.txt")
    expect(response.body).to include("unstaged.txt")
    expect(response.body).to include("staged.txt")
    expect(response.body).to include("deleted.txt")
    expect(response.body).to include("added.txt")
    expect(response.body).to include("modified content")
    expect(response.body).to include("deleted content")
    expect(response.body).to include("staged content")
    expect(response.body).to include("added content")
  end
end
