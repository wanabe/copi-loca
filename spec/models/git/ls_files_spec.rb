# frozen_string_literal: true

require "rails_helper"

RSpec.describe Git::LsFiles do
  describe "#command" do
    it "returns the correct git command" do
      expect(described_class.new.command).to eq("ls-files")
    end
  end

  describe "#initialize" do
    it "sets default values" do
      instance = described_class.new
      expect(instance.entries).to eq([])
      expect(instance.others).to be(false)
      expect(instance.exclude_standard).to be(false)
    end
  end

  describe "#run" do
    it "includes --others when others is true" do
      instance = described_class.new(others: true)
      allow(Git).to receive(:call).and_return("")
      instance.run
      expect(Git).to have_received(:call).with("ls-files", "--others")
    end

    it "includes --exclude-standard when exclude_standard is true" do
      instance = described_class.new(exclude_standard: true)
      allow(Git).to receive(:call).and_return("")
      instance.run
      expect(Git).to have_received(:call).with("ls-files", "--exclude-standard")
    end

    it "includes both flags when both are true" do
      instance = described_class.new(others: true, exclude_standard: true)
      allow(Git).to receive(:call).and_return("")
      instance.run
      expect(Git).to have_received(:call).with("ls-files", "--others", "--exclude-standard")
    end
  end

  describe "Entry" do
    it "has a path attribute" do
      entry = Git::LsFiles::Entry.new(path: "foo.txt")
      expect(entry.path).to eq("foo.txt")
    end
  end
end
