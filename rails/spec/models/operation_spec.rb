require 'rails_helper'

RSpec.describe Operation, type: :model do
  context "validations" do
    it "is valid with command and directory" do
      op = described_class.new(command: 'ls', directory: '/tmp')
      expect(op).to be_valid
    end

    it "is invalid without command" do
      op = described_class.new(command: nil, directory: '/tmp')
      expect(op).not_to be_valid
      expect(op.errors[:command]).to be_present
    end

    it "is invalid without directory" do
      op = described_class.new(command: 'ls', directory: nil)
      expect(op).not_to be_valid
      expect(op.errors[:directory]).to be_present
    end
  end

  describe "#run" do
    it "executes the command and returns output and status" do
      op = described_class.new(command: 'echo hello', directory: Dir.pwd)
      io_double = double('IO', read: "hello\n", close: true)
      allow(IO).to receive(:pipe).and_return([ io_double, io_double ])
      allow(Process).to receive(:spawn).and_return(123)
      allow(Process).to receive(:wait2).and_return([ 123, double('status', exitstatus: 0) ])
      output, status = op.run
      expect(output).to eq("hello\n")
      expect(status).to eq(0)
    end
  end
end
