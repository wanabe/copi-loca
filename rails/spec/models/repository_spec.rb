# frozen_string_literal: true

require "rails_helper"

RSpec.describe Repository do
  let(:repo) { described_class.new(path: "/app") }

  describe "#log" do
    it "parses git log output" do
      allow(repo).to receive(:git).and_return("abc1234|John Doe|Test message\ndef4567|Jane|Another message")
      result = repo.log(2)
      expect(result).to eq([
        { hash: "abc1234", author: "John Doe", message: "Test message" },
        { hash: "def4567", author: "Jane", message: "Another message" }
      ])
    end
  end

  describe "#commit_info" do
    it "parses commit info" do
      allow(repo).to receive(:git).and_return("John Doe|2026-02-24 03:00:00 +0000|2026-02-24 03:01:00 +0000")
      result = repo.commit_info("abc1234")
      expect(result).to eq({ author: "John Doe", author_date: "2026-02-24 03:00:00 +0000",
                             commit_date: "2026-02-24 03:01:00 +0000" })
    end
  end

  describe "#amend_no_edit" do
    it "calls git with --no-edit only" do
      allow(repo).to receive(:git).with("commit --amend --no-edit")
      repo.amend_no_edit
      expect(repo).to have_received(:git).with("commit --amend --no-edit")
    end

    it "calls git with --no-edit and --reset-author" do
      allow(repo).to receive(:git).with("commit --amend --no-edit --reset-author")
      repo.amend_no_edit(reset_author: true)
      expect(repo).to have_received(:git).with("commit --amend --no-edit --reset-author")
    end
  end

  describe "#amend_with_message" do
    it "calls git with message only" do
      allow(repo).to receive(:git).with("commit --amend -m msg")
      repo.amend_with_message("msg")
      expect(repo).to have_received(:git).with("commit --amend -m msg")
    end

    it "calls git with message and --reset-author" do
      allow(repo).to receive(:git).with("commit --amend -m msg --reset-author")
      repo.amend_with_message("msg", reset_author: true)
      expect(repo).to have_received(:git).with("commit --amend -m msg --reset-author")
    end
  end

  describe "#git" do
    it "returns status when return_status is true (no env)" do
      allow(repo).to receive(:`).with("git -C /app status 2>&1").and_return("output")
      allow(Process).to receive(:last_status).and_return(double(success?: true))

      expect(repo.git("status", return_status: true)).to be(true)
      expect(repo).to have_received(:`).with("git -C /app status 2>&1")
      expect(Process).to have_received(:last_status)
    end

    it "returns status when return_status is true (no env, failure)" do
      allow(repo).to receive(:`).with("git -C /app status 2>&1").and_return("output")
      allow(Process).to receive(:last_status).and_return(double(success?: false))

      expect(repo.git("status", return_status: true)).to be(false)
      expect(repo).to have_received(:`).with("git -C /app status 2>&1")
      expect(Process).to have_received(:last_status)
    end

    it "returns status when return_status is true (with env)" do
      fake_w = instance_double(IO)
      allow(IO).to receive(:popen).with(hash_including("FOO" => "bar"), "git -C /app status 2>&1", "w+").and_yield(fake_w)
      allow(fake_w).to receive(:close_write)
      allow(fake_w).to receive(:read).and_return("envok")
      allow(Process).to receive(:last_status).and_return(double(success?: true))

      expect(repo.git("status", env: { "FOO" => "bar" }, return_status: true)).to be(true)
      expect(IO).to have_received(:popen).with(hash_including("FOO" => "bar"), "git -C /app status 2>&1", "w+")
      expect(fake_w).to have_received(:close_write)
      expect(fake_w).to have_received(:read)
      expect(Process).to have_received(:last_status)
    end

    it "returns status when return_status is true (with env, failure)" do
      fake_w = instance_double(IO)
      allow(IO).to receive(:popen).with(hash_including("FOO" => "bar"), "git -C /app status 2>&1", "w+").and_yield(fake_w)
      allow(fake_w).to receive(:close_write)
      allow(fake_w).to receive(:read).and_return("envfail")
      allow(Process).to receive(:last_status).and_return(double(success?: false))

      expect(repo.git("status", env: { "FOO" => "bar" }, return_status: true)).to be(false)
      expect(IO).to have_received(:popen).with(hash_including("FOO" => "bar"), "git -C /app status 2>&1", "w+")
      expect(fake_w).to have_received(:close_write)
      expect(fake_w).to have_received(:read)
      expect(Process).to have_received(:last_status)
    end

    it "runs git command" do
      allow(repo).to receive(:`).with("git -C /app status 2>&1").and_return("ok")
      allow(Process).to receive(:last_status).and_return(double(success?: true))

      expect(repo.git("status")).to eq("ok")
      expect(repo).to have_received(:`).with("git -C /app status 2>&1")
      expect(Process).to have_received(:last_status)
    end

    it "runs git command with env" do
      fake_w = instance_double(IO)
      allow(IO).to receive(:popen).with(hash_including("FOO" => "bar"), "git -C /app status 2>&1", "w+").and_yield(fake_w)
      allow(fake_w).to receive(:close_write)
      allow(fake_w).to receive(:read).and_return("envok")
      allow(Process).to receive(:last_status).and_return(double(success?: true))

      expect(repo.git("status", env: { "FOO" => "bar" })).to eq("envok")
      expect(IO).to have_received(:popen).with(hash_including("FOO" => "bar"), "git -C /app status 2>&1", "w+")
      expect(fake_w).to have_received(:close_write)
      expect(fake_w).to have_received(:read)
      expect(Process).to have_received(:last_status)
    end

    it "raises error on git failure" do
      allow(repo).to receive(:`).with("git -C /app status 2>&1").and_return("error")
      allow(Process).to receive(:last_status).and_return(instance_double(Process::Status, success?: false))
      expect { repo.git("status") }.to raise_error("Git failed: error")
    end
  end

  describe "#ls_files" do
    it "parses ls-files output" do
      allow(repo).to receive(:git).and_return("file1\nfile2")
      expect(repo.ls_files).to eq(%w[file1 file2])
    end
  end

  describe "#untracked_files" do
    it "parses untracked files output" do
      allow(repo).to receive(:git).and_return("ufile1\nufile2")
      expect(repo.untracked_files).to eq(%w[ufile1 ufile2])
    end
  end

  describe "#untracked_diffs" do
    it "returns diffs for untracked files" do
      allow(repo).to receive(:untracked_files).and_return(["ufile1"])
      allow(File).to receive_messages(file?: true, read: "line1\nline2")
      expect(repo.untracked_diffs).to eq([["ufile1", "@@ -0,0 +1,2 @@\n+line1\n+line2"]])
    end

    it "returns Untracked file for missing file" do
      allow(repo).to receive(:untracked_files).and_return(["ufile2"])
      allow(File).to receive(:file?).and_return(false)
      expect(repo.untracked_diffs).to eq([["ufile2", "Untracked file"]])
    end
  end

  describe "#tracked_diffs" do
    it "parses tracked diffs" do
      allow(repo).to receive(:git).and_return("diff --git a/file1 b/file1\n@@ ...\n+line")
      expect(repo.tracked_diffs("abc")).to eq([["file1", "@@ ...\n+line"]])
    end
  end

  describe "#unstaged_diffs" do
    it "combines diff and untracked_diffs" do
      allow(repo).to receive(:git).with("diff").and_return("diff --git a/file1 b/file1\n@@ ...\n+line")
      allow(repo).to receive(:untracked_diffs).and_return([["ufile1", "@@ ...\n+u"]])
      expect(repo.unstaged_diffs).to eq([["file1", "@@ ...\n+line"], ["ufile1", "@@ ...\n+u"]])
    end

    it "returns only untracked if diff_pairs is empty" do
      allow(repo).to receive(:git).with("diff").and_return("")
      allow(repo).to receive(:untracked_diffs).and_return([["ufile1", "@@ ...\n+u"]])
      expect(repo.unstaged_diffs).to eq([["ufile1", "@@ ...\n+u"]])
    end
  end

  describe "#staged_diffs" do
    it "parses staged diffs" do
      allow(repo).to receive(:git).with("diff --cached").and_return("diff --git a/file2 b/file2\n@@ ...\n+line")
      expect(repo.staged_diffs).to eq([["file2", "@@ ...\n+line"]])
    end

    it "returns [] if diff_pairs is empty" do
      allow(repo).to receive(:git).with("diff --cached").and_return("")
      expect(repo.staged_diffs).to eq([])
    end
  end

  describe "#uncommitted_diffs" do
    it "combines unstaged, staged, untracked" do
      allow(repo).to receive_messages(unstaged_diffs: [%w[file1 u1]], staged_diffs: [%w[file2 s2]],
        untracked_diffs: [%w[file3 ut3]])
      expect(repo.uncommitted_diffs).to eq([%w[file1 u1], %w[file2 s2], %w[file3 ut3]])
    end

    it "returns [] if all are empty" do
      allow(repo).to receive_messages(unstaged_diffs: [], staged_diffs: [], untracked_diffs: [])
      expect(repo.uncommitted_diffs).to eq([])
    end
  end

  describe "#commit_message" do
    it "returns commit message" do
      allow(repo).to receive(:git).and_return("msg")
      expect(repo.commit_message("abc")).to eq("msg")
    end
  end

  describe "#stage_file" do
    it "calls git add" do
      allow(repo).to receive(:git)
      repo.stage_file("file1")
      expect(repo).to have_received(:git).with("add -- file1")
      repo.stage_file("file1")
    end
  end

  describe "#unstage_file" do
    it "calls git reset" do
      allow(repo).to receive(:git)
      repo.unstage_file("file1")
      expect(repo).to have_received(:git).with("reset HEAD -- file1")
      repo.unstage_file("file1")
    end

    it "calls git reset with HEAD~1 if amend is true" do
      allow(repo).to receive(:git)
      repo.unstage_file("file1", amend: true)
      expect(repo).to have_received(:git).with("reset HEAD~1 -- file1")
    end
  end

  describe "#commit" do
    it "calls git commit" do
      allow(repo).to receive(:git)
      repo.commit("msg")
      expect(repo).to have_received(:git).with("commit -m msg")
      repo.commit("msg")
    end
  end

  describe "#head_commit_message" do
    it "returns HEAD commit message" do
      allow(repo).to receive(:git).and_return("headmsg")
      expect(repo.head_commit_message).to eq("headmsg")
    end
  end

  describe "#amend_diffs" do
    it "parses amend diffs" do
      allow(repo).to receive(:git).with("diff --cached HEAD~1").and_return("diff --git a/file1 b/file1\n@@ ...\n+line")
      expect(repo.amend_diffs).to eq([["file1", "@@ ...\n+line"]])
    end
  end

  describe "#diff_pairs" do
    it "parses diff pairs" do
      diff_raw = "diff --git a/file1 b/file1\n@@ ...\n+line\ndiff --git a/file2 b/file2\n@@ ...\n+line2"
      pairs = repo.send(:diff_pairs, diff_raw)
      expect(pairs).to eq([["file1", "@@ ...\n+line\n"], ["file2", "@@ ...\n+line2"]])
    end

    it "skips nil paths" do
      diff_raw = "diff --git a/ b/\n@@ ...\n+line"
      pairs = repo.send(:diff_pairs, diff_raw)
      expect(pairs).to eq([])
    end

    it "returns [] for empty string" do
      expect(repo.send(:diff_pairs, "")).to eq([])
    end
  end

  describe "#log_for_rebase" do
    let(:repo) { described_class.new(path: "/mockrepo") }

    it "parses log output with base and limit" do
      allow(repo).to receive(:git).with("log --reverse --format='%H %s' master..HEAD -n5").and_return(
        "abc1234567890123456789012345678901234567890 message1\n" \
        "def4567890123456789012345678901234567890123456 message2"
      )
      result = repo.log_for_rebase(base: "master", limit: 5)
      expect(repo).to have_received(:git).with("log --reverse --format='%H %s' master..HEAD -n5")
      expect(result).to eq([
        { hash: "abc1234567890123456789012345678901234567890", message: "message1" },
        { hash: "def4567890123456789012345678901234567890123456", message: "message2" }
      ])
    end

    it "parses log output with only limit" do
      allow(repo).to receive(:git).with("log --reverse --format='%H %s' -n3").and_return(
        "abc1234567890123456789012345678901234567890 message1\n" \
        "def4567890123456789012345678901234567890123456 message2"
      )
      result = repo.log_for_rebase(limit: 3)
      expect(repo).to have_received(:git).with("log --reverse --format='%H %s' -n3")
      expect(result).to eq([
        { hash: "abc1234567890123456789012345678901234567890", message: "message1" },
        { hash: "def4567890123456789012345678901234567890123456", message: "message2" }
      ])
    end

    it "parses log output with only base" do
      allow(repo).to receive(:git).with("log --reverse --format='%H %s' develop..HEAD").and_return(
        "abc1234567890123456789012345678901234567890 message1\n" \
        "def4567890123456789012345678901234567890123456 message2"
      )
      result = repo.log_for_rebase(base: "develop")
      expect(repo).to have_received(:git).with("log --reverse --format='%H %s' develop..HEAD")
      expect(result).to eq([
        { hash: "abc1234567890123456789012345678901234567890", message: "message1" },
        { hash: "def4567890123456789012345678901234567890123456", message: "message2" }
      ])
    end

    it "parses log output with range" do
      allow(repo).to receive(:git).with("log --reverse --format='%H %s' feature~..feature").and_return(
        "abc1234567890123456789012345678901234567890 message1\n" \
        "def4567890123456789012345678901234567890123456 message2"
      )
      result = repo.log_for_rebase(range: "feature~..feature")
      expect(repo).to have_received(:git).with("log --reverse --format='%H %s' feature~..feature")
      expect(result).to eq([
        { hash: "abc1234567890123456789012345678901234567890", message: "message1" },
        { hash: "def4567890123456789012345678901234567890123456", message: "message2" }
      ])
    end

    it "parses log output with no options" do
      allow(repo).to receive(:git).with("log --reverse --format='%H %s'").and_return(
        "abc1234567890123456789012345678901234567890 message1\n" \
        "def4567890123456789012345678901234567890123456 message2"
      )
      result = repo.log_for_rebase
      expect(repo).to have_received(:git).with("log --reverse --format='%H %s'")
      expect(result).to eq([
        { hash: "abc1234567890123456789012345678901234567890", message: "message1" },
        { hash: "def4567890123456789012345678901234567890123456", message: "message2" }
      ])
    end
  end

  describe "#rebase_i" do
    it "calls git rebase -i with correct env and sequence" do
      steps = [{ action: "pick", hash: "abc1234" }, { action: "squash", hash: "def4567" }]
      allow(repo).to receive(:git)
      fake_tempfile = instance_double(Tempfile, write: nil, flush: nil, path: "/tmp/fake")
      allow(Tempfile).to receive(:create).and_yield(fake_tempfile)
      allow(repo).to receive(:git)
      repo.rebase_i(steps, "basehash")
      expect(Tempfile).to have_received(:create)
      expect(fake_tempfile).to have_received(:write).with("pick abc1234\nsquash def4567\n")
      expect(fake_tempfile).to have_received(:flush)
      expect(repo).to have_received(:git).with(/rebase -i/, env: hash_including("GIT_SEQUENCE_EDITOR", "EDITOR"))
    end

    it "inserts break after consecutive squashes" do
      steps = [
        { action: "pick", hash: "a" },
        { action: "squash", hash: "b" },
        { action: "squash", hash: "c" },
        { action: "pick", hash: "d" }
      ]
      sequence = nil
      fake_tempfile = instance_double(Tempfile, flush: nil, path: "/tmp/fake", close: nil)
      allow(fake_tempfile).to receive(:write) { |s| sequence = s }
      allow(Tempfile).to receive(:create).and_yield(fake_tempfile)
      allow(repo).to receive(:git)
      repo.rebase_i(steps, "basehash")
      expect(Tempfile).to have_received(:create)
      expect(sequence).to include("squash b\nsquash c\nbreak\npick d")
    end

    it "does nothing if steps is empty" do
      allow(repo).to receive(:git)
      fake_tempfile = instance_double(Tempfile, write: nil, flush: nil, path: "/tmp/fake", close: nil)
      allow(Tempfile).to receive(:create).and_yield(fake_tempfile)
      allow(fake_tempfile).to receive(:write).with("")
      repo.rebase_i([], "basehash")
      expect(Tempfile).to have_received(:create).at_least(:once)
      expect(fake_tempfile).to have_received(:write).with("")
    end
  end

  describe "#rebase_continue" do
    it "calls git rebase --continue" do
      allow(repo).to receive(:git)
      repo.rebase_continue
      expect(repo).to have_received(:git).with("rebase --continue")
      repo.rebase_continue
    end
  end

  describe "#current_branch" do
    it "returns current branch name" do
      allow(repo).to receive(:git).with("rev-parse --abbrev-ref HEAD").and_return("main\n")
      expect(repo.current_branch).to eq("main")
    end
  end

  describe "#rebase_directory" do
    it "returns first found rebase dir" do
      allow(File).to receive(:directory?).and_return(false, true)
      expect(repo.rebase_directory).to include("rebase-apply")
    end

    it "returns nil if no rebase dir" do
      allow(File).to receive(:directory?).and_return(false, false)
      expect(repo.rebase_directory).to be_nil
    end
  end

  describe ".instance" do
    it "returns a singleton instance" do
      i1 = described_class.instance
      i2 = described_class.instance
      expect(i1).to be_a(described_class)
      expect(i1).to equal(i2)
    end
  end

  describe "#rebase_status" do
    let(:git_dir) { "/mockrepo/.git/rebase-merge" }

    before do
      allow(repo).to receive_messages(rebase_directory: git_dir, log_for_rebase: [
        { hash: "abc1234567890123456789012345678901234567",
          message: "msg1" },
        { hash: "def4567890123456789012345678901234567890",
          message: "msg2" }
      ])
    end

    it "returns status with done/todo as hashes" do
      allow(File).to receive(:exist?).and_return(true)
      allow(File).to receive(:read).with(File.join(git_dir, "head-name")).and_return("refs/heads/feature\n")
      allow(File).to receive(:read).with(File.join(git_dir, "onto")).and_return("basehash\n")
      allow(File).to receive(:read).with(File.join(git_dir,
        "done")).and_return("pick abc1234567890123456789012345678901234567\n")
      allow(File).to receive(:read).with(File.join(git_dir,
        "git-rebase-todo")).and_return("squash def4567890123456789012345678901234567890\n")
      status = repo.rebase_status
      expect(status[:done]).to eq([{ action: "pick", hash: "abc1234567890123456789012345678901234567",
                                     message: "msg1" }])
      expect(status[:todo]).to eq([{ action: "squash", hash: "def4567890123456789012345678901234567890",
                                     message: "msg2" }])
    end

    it "raises error on unexpected line format" do
      allow(File).to receive(:exist?).and_return(true)
      allow(File).to receive(:read).with(File.join(git_dir, "head-name")).and_return("refs/heads/feature\n")
      allow(File).to receive(:read).with(File.join(git_dir, "onto")).and_return("basehash\n")
      allow(File).to receive(:read).with(File.join(git_dir, "done")).and_return("invalid line\n")
      expect { repo.rebase_status }.to raise_error("Unexpected line in done: invalid line\n")
    end

    it "returns nil if file does not exist" do
      allow(File).to receive(:exist?).and_return(false)
      expect(repo.send(:content, git_dir, "notfound")).to be_nil
    end

    it "returns nil if no rebase dir" do
      allow(repo).to receive(:rebase_directory).and_return(nil)
      expect(repo.rebase_status).to be_nil
    end
  end

  describe "#can_start_rebase?" do
    it "returns false if unstaged changes exist" do
      allow(repo).to receive(:git).with("diff --quiet", return_status: true).and_return(false)
      allow(repo).to receive(:git).with("diff --cached --quiet", return_status: true).and_return(true)
      allow(repo).to receive(:rebase_directory).and_return(nil)
      expect(repo.can_start_rebase?).to be(false)
    end

    it "returns false if staged changes exist" do
      allow(repo).to receive(:git).with("diff --quiet", return_status: true).and_return(true)
      allow(repo).to receive(:git).with("diff --cached --quiet", return_status: true).and_return(false)
      allow(repo).to receive(:rebase_directory).and_return(nil)
      expect(repo.can_start_rebase?).to be(false)
    end

    it "returns false if already rebasing" do
      allow(repo).to receive(:git).with("diff --quiet", return_status: true).and_return(true)
      allow(repo).to receive(:git).with("diff --cached --quiet", return_status: true).and_return(true)
      allow(repo).to receive(:rebase_directory).and_return("/tmp/.git/rebase-merge")
      expect(repo.can_start_rebase?).to be(false)
    end

    it "returns true if clean and not rebasing" do
      allow(repo).to receive(:git).with("diff --quiet", return_status: true).and_return(true)
      allow(repo).to receive(:git).with("diff --cached --quiet", return_status: true).and_return(true)
      allow(repo).to receive(:rebase_directory).and_return(nil)
      expect(repo.can_start_rebase?).to be(true)
    end
  end

  describe "#can_continue_rebase?" do
    it "returns false if not rebasing" do
      allow(repo).to receive(:rebase_directory).and_return(nil)
      expect(repo.can_continue_rebase?).to be(false)
    end

    it "returns false if unstaged changes exist" do
      allow(repo).to receive(:rebase_directory).and_return("/tmp/.git/rebase-merge")
      allow(repo).to receive(:git).with("diff --quiet", return_status: true).and_return(false)
      expect(repo.can_continue_rebase?).to be(false)
    end

    it "returns false if staged changes exist" do
      allow(repo).to receive(:rebase_directory).and_return("/tmp/.git/rebase-merge")
      allow(repo).to receive(:git).with("diff --quiet", return_status: true).and_return(true)
      allow(repo).to receive(:git).with("diff --cached --quiet", return_status: true).and_return(false)
      expect(repo.can_continue_rebase?).to be(false)
    end

    it "returns true if rebasing and clean" do
      allow(repo).to receive(:rebase_directory).and_return("/tmp/.git/rebase-merge")
      allow(repo).to receive(:git).with("diff --quiet", return_status: true).and_return(true)
      allow(repo).to receive(:git).with("diff --cached --quiet", return_status: true).and_return(true)
      expect(repo.can_continue_rebase?).to be(true)
    end
  end

  describe "#pick_line_patch" do
    let(:file_path) { "foo.rb" }

    context "with simple hunk" do
      let(:hunk_text) do
        <<~HUNK
          @@ -1,3 +1,3 @@
           some context line
          -old line
          +new line
           other context line
        HUNK
      end

      let(:diffs) { [[file_path, hunk_text]] }
      let(:repo) { described_class.new }

      context "when selecting the '+' line" do
        let(:diff_line_num) { 4 } # header(1) + first content(2) + '-'(3) + '+'(4)

        it "returns a patch containing the selected + line when not reversed" do
          patch = repo.pick_line_patch(file_path, diffs, diff_line_num, reverse: false)

          expect(patch).to eq(<<~PATCH)
            diff --git a/#{file_path} b/#{file_path}
            --- a/#{file_path}
            +++ b/#{file_path}
            @@ -1,3 +1,4 @@
             some context line
             old line
            +new line
             other context line
          PATCH
        end

        it "returns a patch where the selected + line becomes - when reversed" do
          patch = repo.pick_line_patch(file_path, diffs, diff_line_num, reverse: true)

          expect(patch).to eq(<<~PATCH)
            diff --git a/#{file_path} b/#{file_path}
            --- a/#{file_path}
            +++ b/#{file_path}
            @@ -1,3 +1,2 @@
             some context line
            -new line
             other context line
          PATCH
        end
      end

      context "when selecting the '-' line" do
        let(:diff_line_num) { 3 }

        it "returns a patch containing the selected - line when not reversed" do
          patch = repo.pick_line_patch(file_path, diffs, diff_line_num, reverse: false)

          expect(patch).to eq(<<~PATCH)
            diff --git a/#{file_path} b/#{file_path}
            --- a/#{file_path}
            +++ b/#{file_path}
            @@ -1,3 +1,2 @@
             some context line
            -old line
             other context line
          PATCH
        end

        it "returns a patch where the selected - line becomes + when reversed" do
          patch = repo.pick_line_patch(file_path, diffs, diff_line_num, reverse: true)

          expect(patch).to eq(<<~PATCH)
            diff --git a/#{file_path} b/#{file_path}
            --- a/#{file_path}
            +++ b/#{file_path}
            @@ -1,3 +1,4 @@
             some context line
            +old line
             new line
             other context line
          PATCH
        end
      end
    end

    context "with long hunks" do
      let(:hunk_text) do
        <<~HUNK
          @@ -1,5 +1,5 @@
           line 1
           line 2
           line 3
           line 4
           line 5
          @@ -10,11 +10,11 @@
           line 10
           line 11
           line 12
          +first added line
          -first removed line
           line 14
          +second added line; it will be selected
          -second removed line
           line 16
          +third added line
          -third removed line
           line 18
           line 19
           line 20
        HUNK
      end

      let(:diffs) { [[file_path, hunk_text]] }
      let(:repo) { described_class.new }

      it "returns reduced hunk" do
        patch = repo.pick_line_patch(file_path, diffs, 14, reverse: false)

        expect(patch).to eq(<<~PATCH)
          diff --git a/#{file_path} b/#{file_path}
          --- a/#{file_path}
          +++ b/#{file_path}
          @@ -12,6 +12,7 @@
           line 12
           first removed line
           line 14
          +second added line; it will be selected
           second removed line
           line 16
           third removed line
        PATCH
      end
    end
  end

  describe "#stage_line" do
    let(:repo) { described_class.new }
    let(:file_path) { "foo.rb" }
    let(:diffs) { [[file_path, "@@ -1,1 +1,1 @@\n+line\n"]] }

    it "asks for unstaged diffs, builds a patch without reversing, and applies it cached" do
      allow(repo).to receive(:unstaged_diffs).and_return(diffs)
      allow(repo).to receive(:pick_line_patch).with(file_path, diffs, 5, reverse: false).and_return("patch-body")

      fake_io = StringIO.new
      allow(repo).to receive(:git) do |cmd, **_kwargs, &blk|
        expect(cmd).to eq("apply --cached -")
        blk.call(fake_io)
        "ok"
      end

      repo.stage_line(file_path, 5)

      expect(fake_io.string).to eq("patch-body")
      expect(repo).to have_received(:unstaged_diffs)
      expect(repo).to have_received(:pick_line_patch).with(file_path, diffs, 5, reverse: false)
      expect(repo).to have_received(:git).with("apply --cached -", any_args)
    end
  end

  describe "#unstage_line" do
    let(:repo) { described_class.new }
    let(:file_path) { "foo.rb" }
    let(:diffs) { [[file_path, "@@ -1,1 +1,1 @@\n+line\n"]] }

    it "asks for staged diffs with amend flag, builds a reversed patch, and applies it cached when amend: true" do
      allow(repo).to receive(:staged_diffs).with(amend: true).and_return(diffs)
      allow(repo).to receive(:pick_line_patch).with(file_path, diffs, 3, reverse: true).and_return("reversed-patch")

      fake_io = StringIO.new
      allow(repo).to receive(:git) do |cmd, **_kwargs, &blk|
        expect(cmd).to eq("apply --cached -")
        blk.call(fake_io)
        "ok"
      end

      repo.unstage_line(file_path, 3, amend: true)

      expect(fake_io.string).to eq("reversed-patch")
      expect(repo).to have_received(:staged_diffs).with(amend: true)
      expect(repo).to have_received(:pick_line_patch).with(file_path, diffs, 3, reverse: true)
      expect(repo).to have_received(:git).with("apply --cached -", any_args)
    end

    it "asks for staged diffs with amend: false and builds a reversed patch when not amending" do
      allow(repo).to receive(:staged_diffs).with(amend: false).and_return(diffs)
      allow(repo).to receive(:pick_line_patch).with(file_path, diffs, 7, reverse: true).and_return("reversed-patch-2")

      fake_io = StringIO.new
      allow(repo).to receive(:git) do |cmd, **_kwargs, &blk|
        expect(cmd).to eq("apply --cached -")
        blk.call(fake_io)
        "ok"
      end

      repo.unstage_line(file_path, 7, amend: false)

      expect(fake_io.string).to eq("reversed-patch-2")
      expect(repo).to have_received(:staged_diffs).with(amend: false)
      expect(repo).to have_received(:pick_line_patch).with(file_path, diffs, 7, reverse: true)
      expect(repo).to have_received(:git).with("apply --cached -", any_args)
    end
  end
end
