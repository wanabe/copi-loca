# frozen_string_literal: true

require "rails_helper"

RSpec.describe Git::Command do
  describe "#command" do
    it "raises NotImplementedError" do
      expect { described_class.new.command }.to raise_error(NotImplementedError)
    end
  end

  describe "#run" do
    let(:dummy_class) do
      Class.new(Git::Command) do
        def command
          "dummy"
        end

        def parse(result)
          "parsed: #{result}"
        end
      end
    end

    let(:instance) { dummy_class.new }

    before do
      allow(Git).to receive(:call).and_return("result")
    end

    it "calls Git.call with command and parses the result" do
      expect(instance.run).to eq("parsed: result")
      expect(Git).to have_received(:call).with("dummy")
    end

    it "raises if result is not a String" do
      allow(Git).to receive(:call).and_return(123)
      expect { instance.run }.to raise_error("Unexpected result")
    end
  end
end
