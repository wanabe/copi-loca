# frozen_string_literal: true

class Views::CustomAgents::New < Views::Base
  def initialize(custom_agent:)
    @custom_agent = custom_agent
  end

  def view_template
    view_context.content_for(:title, "New custom agent")

    h1 { plain "New custom agent" }

    render Components::CustomAgents::FormComponent.new(custom_agent: @custom_agent)

    br

    div do
      a(href: custom_agents_path) { plain "Back to custom agents" }
    end
  end
end
