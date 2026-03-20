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
    let(:prompt) { described_class.new(id: 1) }

    it "loads text from file" do
      allow(File).to receive(:read).with("#{Prompt::PATH_PREFIX}1#{Prompt::PATH_SUFFIX}").and_return("Loaded text")
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
      expect(prompt.errors[:base]).to match([/Cannot save file/])
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
    it "calls IO.popen and saves response" do
      io = instance_double(IO, pid: 123)
      allow(IO).to receive(:popen).and_yield(io)
      allow(File).to receive(:write)
      allow(io).to receive(:gets).and_return("response\n", nil)
      response = nil
      allow(Response).to receive(:new).and_wrap_original do |m, *args|
        response = m.call(*args)
        allow(response).to receive(:save).and_return(true)
        response
      end
      allow(File).to receive(:exist?).and_return(false, true)
      allow(File).to receive(:delete).and_return(true)

      expect(prompt.run).to eq(response)
      expect(response.text).to eq("response\n")

      expect(IO).to have_received(:popen)
      expect(File).to have_received(:write).with("#{Prompt::PATH_PREFIX}1/pid", "123")
      expect(io).to have_received(:gets).twice
      expect(File).to have_received(:exist?).with("#{Prompt::PATH_PREFIX}1/pid").twice
      expect(File).to have_received(:delete).with("#{Prompt::PATH_PREFIX}1/pid")
      expect(response).to have_received(:save)
    end

    it "raises if already running" do
      allow(prompt).to receive(:running?).and_return(true)
      expect { prompt.run }.to raise_error("Prompt is already running")
    end

    it "runs multiple times if n > 1" do
      allow(File).to receive(:exist?).and_return(false)
      allow(IO).to receive(:popen)
      prompt.run(5)
      expect(IO).to have_received(:popen).exactly(5).times
    end
  end

  describe "#pid" do
    it "returns pid if running" do
      allow(File).to receive(:exist?).and_return(true)
      allow(File).to receive(:read).with("#{Prompt::PATH_PREFIX}1/pid").and_return("123")
      expect(prompt.pid).to eq(123)
    end

    it "returns nil if not running" do
      allow(File).to receive(:exist?).and_return(false)
      expect(prompt.pid).to be_nil
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
      allow(Dir).to receive(:glob).and_return(["/fake/1/prompt.md", "/fake/ignore/prompt.md"])
      prompt = instance_double(described_class, id: 1)
      allow(described_class).to receive(:from_path).with("/fake/1/prompt.md").and_return(prompt)
      allow(described_class).to receive(:from_path).with("/fake/ignore/prompt.md").and_return(nil)
      expect(described_class.all).to eq([prompt])
      expect(Dir).to have_received(:glob).with("#{Prompt::PATH_PREFIX}*#{Prompt::PATH_SUFFIX}")
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
