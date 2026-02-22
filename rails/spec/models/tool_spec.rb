require 'rails_helper'

RSpec.describe Tool, type: :model do
  describe "after_initialize callback" do
    it "defines call method with script as body" do
      tool = described_class.new(script: "'hello'", name: "test")
      expect(tool).to respond_to(:call)
      expect(tool.call).to eq('hello')
    end

    it "does not define call method if script has syntax error" do
      expect {
        tool = described_class.new(script: "def x (", name: "broken")
        expect(tool).not_to respond_to(:call)
      }.not_to raise_error
      # No exception should be raised, app remains stable
    end
  end
end
