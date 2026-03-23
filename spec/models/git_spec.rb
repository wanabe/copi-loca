# frozen_string_literal: true

require "rails_helper"

RSpec.describe Git do
  describe ".call!" do
    it "executes git command and returns output when successful" do
      process_status_double = instance_double(Process::Status, success?: true)
      allow(IO).to receive(:popen).and_return([process_status_double, "success output"])
      output = described_class.call!("status")
      expect(output).to eq("success output")
    end

    it "yields to block with IO object" do
      process_status_double = instance_double(Process::Status, success?: true)
      io_double = instance_double(IO, read: "input data", close_write: nil, pid: 1234)
      allow(IO).to receive(:popen).and_yield(io_double).and_return([process_status_double, "output"])
      allow(Process).to receive(:wait2).with(1234).and_return([1234, process_status_double])
      described_class.call!("some-command") do |io|
        expect(io).to eq(io_double)
      end
      expect(io_double).to have_received(:close_write)
      expect(io_double).to have_received(:read)
    end

    it "raises error when git command fails" do
      process_status_double = instance_double(Process::Status, success?: false)
      allow(IO).to receive(:popen).and_return([process_status_double, "error output"])
      expect { described_class.call!("status") }.to raise_error("Git failed: error output")
    end
  end

  describe ".call?" do
    it "returns status when return_status is true" do
      process_status_double = instance_double(Process::Status, success?: true)
      allow(IO).to receive(:popen).and_return([process_status_double, "output"])
      status = described_class.call?("status")
      expect(status).to be true
    end
  end

  describe ".call" do
    it "returns output even when git command fails" do
      process_status_double = instance_double(Process::Status, success?: false)
      allow(IO).to receive(:popen).and_return([process_status_double, "error output"])
      output = described_class.call("status")
      expect(output).to eq("error output")
    end
  end
end
