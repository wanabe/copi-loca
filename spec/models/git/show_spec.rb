# frozen_string_literal: true

require "rails_helper"

RSpec.describe Git::Show do
  describe "#command" do
    it "returns 'show'" do
      expect(described_class.new.command).to eq("show")
    end
  end

  describe "#run" do
    let(:show) { described_class.new(ref: "main", path: "README.md") }

    it "calls super with correct arguments" do
      allow(Git).to receive(:call).and_return("Sample content of README.md")
      show.run
      expect(Git).to have_received(:call).with("show", "main:README.md")
      expect(show.content).to eq("Sample content of README.md")
    end
  end
end
