# frozen_string_literal: true

class Views::Sessions::Edit < Components::Base
  def initialize(session:, custom_agents:, models:, tools:)
    @session = session
    @custom_agents = custom_agents
    @models = models
    @tools = tools
  end

  def view_template
    view_context.content_for(:title, "Editing session")

    h1 { plain "Editing session" }

    render Components::Sessions::FormComponent.new(session: @session, custom_agents: @custom_agents, models: @models, tools: @tools)

    br
  end
end
