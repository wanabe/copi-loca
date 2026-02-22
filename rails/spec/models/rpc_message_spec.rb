require 'rails_helper'

RSpec.describe RpcMessage, type: :model do
  describe "#initialize" do
    it "sets direction and message_type" do
      rpc_message = described_class.new(direction: :outgoing, message_type: :request, rpc_id: "id", method: "foo", params: {})
      expect(rpc_message.direction).to eq("outgoing")
      expect(rpc_message.message_type).to eq("request")
    end
  end

  describe ".validations" do
    it "validates presence of direction and message_type" do
      rpc_message = described_class.new(direction: nil, message_type: nil)
      rpc_message.valid?
      expect(rpc_message.errors[:direction]).to be_present
      expect(rpc_message.errors[:message_type]).to be_present
    end
  end
end
