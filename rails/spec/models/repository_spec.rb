require 'rails_helper'

RSpec.describe Repository, type: :model do
  let(:repo) { described_class.new(path: '/app') }

  describe '#log' do
    it 'parses git log output' do
      allow(repo).to receive(:git).and_return("abc123|John Doe|Test message\ndef456|Jane|Another message")
      result = repo.log(2)
      expect(result).to eq([
        { hash: 'abc123', author: 'John Doe', message: 'Test message' },
        { hash: 'def456', author: 'Jane', message: 'Another message' }
      ])
    end
  end

  describe '#commit_info' do
    it 'parses commit info' do
      allow(repo).to receive(:git).and_return("John Doe|2026-02-24 03:00:00 +0000|2026-02-24 03:01:00 +0000")
      result = repo.commit_info('abc123')
      expect(result).to eq({ author: 'John Doe', author_date: '2026-02-24 03:00:00 +0000', commit_date: '2026-02-24 03:01:00 +0000' })
    end
  end

  describe '#amend_no_edit' do
    it 'calls git with --no-edit only' do
      allow(repo).to receive(:git).with("commit --amend --no-edit")
      repo.amend_no_edit
      expect(repo).to have_received(:git).with("commit --amend --no-edit")
    end

    it 'calls git with --no-edit and --reset-author' do
      allow(repo).to receive(:git).with("commit --amend --no-edit --reset-author")
      repo.amend_no_edit(reset_author: true)
      expect(repo).to have_received(:git).with("commit --amend --no-edit --reset-author")
    end
  end

  describe '#amend_with_message' do
    it 'calls git with message only' do
      allow(repo).to receive(:git).with("commit --amend -m msg")
      repo.amend_with_message('msg')
      expect(repo).to have_received(:git).with("commit --amend -m msg")
    end

    it 'calls git with message and --reset-author' do
      allow(repo).to receive(:git).with("commit --amend -m msg --reset-author")
      repo.amend_with_message('msg', reset_author: true)
      expect(repo).to have_received(:git).with("commit --amend -m msg --reset-author")
    end
  end

  describe '#git' do
    it 'runs git command' do
      expect(repo).to receive(:`).with("git -C /app status 2>&1").and_return("ok")
      expect(repo.git("status")).to eq("ok")
    end
  end

  describe '#ls_files' do
    it 'parses ls-files output' do
      allow(repo).to receive(:git).and_return("file1\nfile2")
      expect(repo.ls_files).to eq([ "file1", "file2" ])
    end
  end

  describe '#untracked_files' do
    it 'parses untracked files output' do
      allow(repo).to receive(:git).and_return("ufile1\nufile2")
      expect(repo.untracked_files).to eq([ "ufile1", "ufile2" ])
    end
  end

  describe '#untracked_diffs' do
    it 'returns diffs for untracked files' do
      allow(repo).to receive(:untracked_files).and_return([ "ufile1" ])
      allow(File).to receive(:file?).and_return(true)
      allow(File).to receive(:read).and_return("line1\nline2")
      expect(repo.untracked_diffs).to eq([ [ "ufile1", "@@ -0,0 +1,2 @@\n+line1\n+line2" ] ])
    end
    it 'returns Untracked file for missing file' do
      allow(repo).to receive(:untracked_files).and_return([ "ufile2" ])
      allow(File).to receive(:file?).and_return(false)
      expect(repo.untracked_diffs).to eq([ [ "ufile2", "Untracked file" ] ])
    end
  end

  describe '#tracked_diffs' do
    it 'parses tracked diffs' do
      allow(repo).to receive(:git).and_return("diff --git a/file1 b/file1\n@@ ...\n+line")
      expect(repo.tracked_diffs("abc")).to eq([ [ "file1", "@@ ...\n+line" ] ])
    end
  end

  describe '#unstaged_diffs' do
    it 'combines diff and untracked_diffs' do
      allow(repo).to receive(:git).with("diff").and_return("diff --git a/file1 b/file1\n@@ ...\n+line")
      allow(repo).to receive(:untracked_diffs).and_return([ [ "ufile1", "@@ ...\n+u" ] ])
      expect(repo.unstaged_diffs).to eq([ [ "file1", "@@ ...\n+line" ], [ "ufile1", "@@ ...\n+u" ] ])
    end
  end

  describe '#staged_diffs' do
    it 'parses staged diffs' do
      allow(repo).to receive(:git).with("diff --cached").and_return("diff --git a/file2 b/file2\n@@ ...\n+line")
      expect(repo.staged_diffs).to eq([ [ "file2", "@@ ...\n+line" ] ])
    end
  end

  describe '#uncommitted_diffs' do
    it 'combines unstaged, staged, untracked' do
      allow(repo).to receive(:unstaged_diffs).and_return([ [ "file1", "u1" ] ])
      allow(repo).to receive(:staged_diffs).and_return([ [ "file2", "s2" ] ])
      allow(repo).to receive(:untracked_diffs).and_return([ [ "file3", "ut3" ] ])
      expect(repo.uncommitted_diffs).to eq([ [ "file1", "u1" ], [ "file2", "s2" ], [ "file3", "ut3" ] ])
    end
  end

  describe '#commit_message' do
    it 'returns commit message' do
      allow(repo).to receive(:git).and_return("msg")
      expect(repo.commit_message("abc")).to eq("msg")
    end
  end

  describe '#stage_file' do
    it 'calls git add' do
      expect(repo).to receive(:git).with("add -- file1")
      repo.stage_file("file1")
    end
  end

  describe '#unstage_file' do
    it 'calls git reset' do
      expect(repo).to receive(:git).with("reset HEAD -- file1")
      repo.unstage_file("file1")
    end
    it 'calls git reset with custom commit' do
      expect(repo).to receive(:git).with("reset abc -- file1")
      repo.unstage_file("file1", commit: "abc")
    end
  end

  describe '#commit' do
    it 'calls git commit' do
      expect(repo).to receive(:git).with("commit -m msg")
      allow_any_instance_of(String).to receive(:shellescape).and_return("msg")
      repo.commit("msg")
    end
  end

  describe '#head_commit_message' do
    it 'returns HEAD commit message' do
      allow(repo).to receive(:git).and_return("headmsg")
      expect(repo.head_commit_message).to eq("headmsg")
    end
  end

  describe '#amend_diffs' do
    it 'parses amend diffs' do
      allow(repo).to receive(:git).with('diff --cached HEAD~1').and_return("diff --git a/file1 b/file1\n@@ ...\n+line")
      expect(repo.amend_diffs).to eq([ [ "file1", "@@ ...\n+line" ] ])
    end
  end

  describe '#diff_pairs' do
    it 'parses diff pairs' do
      diff_raw = "diff --git a/file1 b/file1\n@@ ...\n+line\ndiff --git a/file2 b/file2\n@@ ...\n+line2"
      pairs = repo.send(:diff_pairs, diff_raw)
      expect(pairs).to eq([ [ "file1", "@@ ...\n+line\n" ], [ "file2", "@@ ...\n+line2" ] ])
    end
    it 'skips nil paths' do
      diff_raw = "diff --git a/ b/\n@@ ...\n+line"
      pairs = repo.send(:diff_pairs, diff_raw)
      expect(pairs).to eq([])
    end
  end
end
