# frozen_string_literal: true

require "rails_helper"

RSpec.describe Git::LsTree do
  describe "#command" do
    it "returns 'ls-tree'" do
      expect(described_class.new.command).to eq("ls-tree")
    end
  end

  describe "#run" do
    let(:ls_tree) { described_class.new(ref: "main", path: "lib") }

    it "calls super with correct arguments" do
      allow(Git).to receive(:call).and_return(<<~OUTPUT)
        010000 blob #{'deadbeaf' * 5}\tsome_file.rb
        40000 tree #{'deadbeaf' * 5}\tsome_directory
      OUTPUT
      ls_tree.run
      expect(Git).to have_received(:call).with("ls-tree", "main", "--", "lib")
      expect(ls_tree.entries.size).to eq(2)
      expect(ls_tree.entries[0].mode).to eq("010000")
      expect(ls_tree.entries[0].type).to eq("blob")
      expect(ls_tree.entries[0].hash).to eq("deadbeaf" * 5)
      expect(ls_tree.entries[0].path).to eq("some_file.rb")
      expect(ls_tree.entries[1].mode).to eq("40000")
      expect(ls_tree.entries[1].type).to eq("tree")
      expect(ls_tree.entries[1].hash).to eq("deadbeaf" * 5)
      expect(ls_tree.entries[1].path).to eq("some_directory")
    end
  end
end
