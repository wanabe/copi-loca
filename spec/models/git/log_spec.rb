# frozen_string_literal: true

require "rails_helper"

RSpec.describe Git::Log do
  describe "#run" do
    it "parses git log output correctly" do
      log = described_class.new(ref: "main")
      allow(Git).to receive(:call).and_return(<<~OUTPUT)
        1234567890abcdef\tJohn Doe\tjohn.doe@example.com\t2022-01-01T12:00:00Z\t2022-01-01T12:01:00Z\tInitial commit
      OUTPUT
      log.run
      expect(Git).to have_received(:call).with("log", "--pretty=format:%H%x09%an%x09%ae%x09%aI%x09%cI%x09%s", "main")
      expect(log.commits.first.commit_hash).to eq("1234567890abcdef")
      expect(log.commits.first.author_name).to eq("John Doe")
      expect(log.commits.first.author_email).to eq("john.doe@example.com")
      expect(log.commits.first.author_date).to eq(DateTime.parse("2022-01-01T12:00:00Z"))
      expect(log.commits.first.committer_date).to eq(DateTime.parse("2022-01-01T12:01:00Z"))
      expect(log.commits.first.message).to eq("Initial commit")
    end
  end
end
