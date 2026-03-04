# frozen_string_literal: true

class Views::CustomAgents::Index < Views::Base
  def initialize(custom_agents:)
    @custom_agents = custom_agents
  end

  def view_template
    view_context.content_for(:title, "Custom agents")

    render Components::CustomAgents::IndexComponent.new(custom_agents: @custom_agents)
  end
end
