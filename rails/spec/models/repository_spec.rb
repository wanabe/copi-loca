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
end
