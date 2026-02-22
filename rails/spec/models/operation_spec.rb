require 'rails_helper'

RSpec.describe Operation, type: :model do
  context "validations" do
    it "is valid with command and directory" do
      operation = described_class.new(command: 'ls', directory: '/tmp')
      expect(operation).to be_valid
    end

    it "is invalid without command" do
      operation = described_class.new(command: nil, directory: '/tmp')
      expect(operation).not_to be_valid
      expect(operation.errors[:command]).to be_present
    end

    it "is invalid without directory" do
      operation = described_class.new(command: 'ls', directory: nil)
      expect(operation).not_to be_valid
      expect(operation.errors[:directory]).to be_present
    end
  end

  describe "#run" do
    it "executes the command and returns output and status" do
      operation = described_class.new(command: 'echo hello', directory: Dir.pwd)
      io_double = double('IO', read: "hello\n", close: true)
      allow(IO).to receive(:pipe).and_return([ io_double, io_double ])
      allow(Process).to receive(:spawn).and_return(123)
      allow(Process).to receive(:wait2).and_return([ 123, double('status', exitstatus: 0) ])
      output, status = operation.run
      expect(output).to eq("hello\n")
      expect(status).to eq(0)
    end
  end
end
