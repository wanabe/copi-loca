# frozen_string_literal: true

require "rails_helper"

RSpec.describe Git do
  describe ".call" do
    it "executes git command and returns output when successful" do
      allow(IO).to receive(:popen).and_return("success output")
      allow(Process).to receive(:last_status).and_return(double(success?: true))
      output = described_class.call("status")
      expect(output).to eq("success output")
    end

    it "yields to block with IO object" do
      io_double = instance_double(IO, read: "input data", close_write: nil)
      allow(IO).to receive(:popen).and_yield(io_double).and_return("output")
      allow(Process).to receive(:last_status).and_return(double(success?: true))
      described_class.call("some-command") do |io|
        expect(io).to eq(io_double)
      end
      expect(io_double).to have_received(:close_write)
      expect(io_double).to have_received(:read)
    end

    it "raises error when git command fails" do
      allow(IO).to receive(:popen).and_return("error output")
      allow(Process).to receive(:last_status).and_return(double(success?: false))
      expect { described_class.call("status") }.to raise_error("Git failed: error output")
    end

    it "returns status when return_status is true" do
      allow(IO).to receive(:popen).and_return("output")
      allow(Process).to receive(:last_status).and_return(double(success?: true))
      status = described_class.call("status", return_status: true)
      expect(status).to be true
    end
  end
end
