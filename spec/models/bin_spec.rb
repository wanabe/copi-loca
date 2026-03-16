# frozen_string_literal: true

require "rails_helper"

RSpec.describe Bin do
  describe "#run" do
    let(:bin) { described_class.new(id: "test_bin.rb") }
    let(:bin_path) { "#{Bin::PATH_PREFIX}test_bin.rb#{Bin::PATH_SUFFIX}" }

    before do
      allow(File).to receive(:exist?).with(bin_path).and_return(true)
      allow(IO).to receive(:popen).with(["ruby", bin_path], err: %i[child out]).and_yield(StringIO.new("output\n"))
      allow(Process).to receive(:waitpid2).and_return([123, instance_double(Process::Status, to_i: 0)])
    end

    it "runs the bin file and captures output" do
      status, output = bin.run
      expect(status).to eq(0)
      expect(output).to eq("output\n")
    end
  end

  describe "#load" do
    it "returns self" do
      bin = described_class.new(id: "test_bin.rb")
      expect(bin.load).to eq(bin)
    end
  end
end
