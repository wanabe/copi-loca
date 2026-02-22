require 'rails_helper'

RSpec.describe Tool, type: :model do

  describe "after_initialize callback" do
    it "defines call method with script as body" do
      tool = described_class.new(script: "'hello'", name: "test")
      expect(tool).to respond_to(:call)
      expect(tool.call).to eq('hello')
    end
  end
end
