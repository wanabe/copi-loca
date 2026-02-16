require "rails_helper"

RSpec.describe EventsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/sessions/1/events").to route_to("events#index", session_id: "1")
    end

    it "routes to #show" do
      expect(get: "/sessions/1/events/2").to route_to("events#show", session_id: "1", id: "2")
    end
  end
end
