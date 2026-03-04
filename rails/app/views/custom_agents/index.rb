# frozen_string_literal: true

class Views::CustomAgents::Index < Views::Base
  def initialize(custom_agents:)
    @custom_agents = custom_agents
  end

  def view_template
    h1 { plain "Custom agents" }
    div(id: "custom_agents") do
      @custom_agents.each do |custom_agent|
        render Components::CustomAgents::CustomAgentComponent.new(custom_agent: custom_agent)
        p { a(href: custom_agent_path(custom_agent)) { plain "Show this custom agent" } }
      end
    end

    div { a(href: new_custom_agent_path) { plain "New custom agent" } }
  end
end
