require "rails_helper"

RSpec.describe CustomAgentsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/custom_agents").to route_to("custom_agents#index")
    end

    it "routes to #new" do
      expect(get: "/custom_agents/new").to route_to("custom_agents#new")
    end

    it "routes to #show" do
      expect(get: "/custom_agents/1").to route_to("custom_agents#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/custom_agents/1/edit").to route_to("custom_agents#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/custom_agents").to route_to("custom_agents#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/custom_agents/1").to route_to("custom_agents#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/custom_agents/1").to route_to("custom_agents#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/custom_agents/1").to route_to("custom_agents#destroy", id: "1")
    end
  end
end
