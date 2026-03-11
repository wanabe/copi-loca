# frozen_string_literal: true

require "rails_helper"

RSpec.describe Prompt do
  let(:prompt) { described_class.new(id: 1, text: "Test prompt") }

  describe "validations" do
    it "is valid with id and text" do
      expect(prompt).to be_valid
    end

    it "is invalid without id" do
      prompt.id = nil
      expect(prompt).not_to be_valid
    end

    it "is invalid without text" do
      prompt.text = nil
      expect(prompt).not_to be_valid
    end
  end

  describe "#load" do
    it "loads text from file" do
      allow(File).to receive(:read).and_return("Loaded text")
      expect(prompt.load.text).to eq("Loaded text")
    end

    it "returns nil if file missing" do
      allow(File).to receive(:read).and_raise(Errno::ENOENT)
      expect(prompt.load).to be_nil
    end
  end

  describe "#save" do
    it "writes text to file if valid" do
      allow(File).to receive(:write).and_return(true)
      expect(prompt.save).to be true
    end

    it "does not write if invalid" do
      prompt.id = nil
      expect(prompt.save).to be false
    end

    it "adds error if directory missing" do
      allow(File).to receive(:write).and_raise(Errno::ENOENT.new("dir"))
      expect(prompt.save).to be false
      expect(prompt.errors[:base]).to match([/Directory does not exist/])
    end
  end

  describe "#destroy!" do
    it "deletes the file" do
      allow(File).to receive(:delete).and_return(true)
      expect { prompt.destroy! }.not_to raise_error
    end

    it "also destroys associated response" do
      response_double = instance_double(Response, destroy!: true)
      allow(prompt).to receive(:response).and_return(response_double)
      allow(File).to receive(:delete).and_return(true)
      expect { prompt.destroy! }.not_to raise_error
      expect(response_double).to have_received(:destroy!)
    end
  end

  describe "#persisted?" do
    it "returns true if file exists" do
      allow(File).to receive(:exist?).and_return(true)
      expect(prompt.persisted?).to be true
    end

    it "returns false if file does not exist" do
      allow(File).to receive(:exist?).and_return(false)
      expect(prompt.persisted?).to be false
    end
  end

  describe "#run" do
    it "calls system and saves response" do
      allow(IO).to receive(:pipe).and_return([double(read: "response"), double(close: true)])
      allow(prompt).to receive(:system).and_return(true)
      response_double = double(save: true)
      allow(Response).to receive(:new).and_return(response_double)
      expect(prompt.run).to be true
    end
  end

  describe "#response" do
    it "fetches response by id" do
      response_double = double
      allow(Response).to receive(:find_by).with(id: 1).and_return(response_double)
      expect(prompt.response).to eq(response_double)
    end
  end

  describe ".find_by" do
    it "loads prompt by id" do
      prompt = instance_double(described_class)
      allow(prompt).to receive(:load).and_return(prompt)
      allow(described_class).to receive(:new).and_return(prompt)
      expect(described_class.find_by(id: 1)).to eq(prompt)
      expect(described_class).to have_received(:new).with(id: 1)
      expect(prompt).to have_received(:load)
    end
  end

  describe ".find" do
    it "returns prompt if found" do
      allow(described_class).to receive(:find_by).and_return(prompt)
      expect(described_class.find(1)).to eq(prompt)
    end

    it "raises if not found" do
      allow(described_class).to receive(:find_by).and_return(nil)
      expect { described_class.find(1) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe ".all" do
    it "returns all prompts" do
      allow(Dir).to receive(:glob).and_return(["/fake/1.prompt.md", "/fake/ignore.prompt.md"])
      prompt = instance_double(described_class)
      allow(prompt).to receive(:load).and_return(prompt)
      allow(described_class).to receive(:new).and_return(prompt)
      expect(described_class.all).to eq([prompt])
      expect(Dir).to have_received(:glob).with(File.join(Prompt::PATH_PREFIX, "*#{Prompt::PATH_SUFFIX}"))
      expect(described_class).to have_received(:new).with(id: 1).once
      expect(described_class).not_to have_received(:new).with(id: "ignore")
      expect(prompt).to have_received(:load).once
    end
  end

  describe ".max_id" do
    it "returns max id" do
      allow(described_class).to receive(:all).and_return([prompt, described_class.new(id: 2, text: "x")])
      expect(described_class.max_id).to eq(2)
    end

    it "returns 0 if none" do
      allow(described_class).to receive(:all).and_return([])
      expect(described_class.max_id).to eq(0)
    end
  end
end
