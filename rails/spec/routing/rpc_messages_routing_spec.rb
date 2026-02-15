require "rails_helper"

RSpec.describe RpcMessagesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/sessions/42/rpc_messages").to route_to("rpc_messages#index", session_id: "42")
    end

    it "routes to #show" do
      expect(get: "/sessions/42/rpc_messages/99").to route_to("rpc_messages#show", session_id: "42", id: "99")
    end
  end
end
