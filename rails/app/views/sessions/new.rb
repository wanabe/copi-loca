# frozen_string_literal: true

module Views
  module Sessions
    class New < Components::Base
      def initialize(session:, custom_agents:, models:, tools:)
        @session = session
        @custom_agents = custom_agents
        @models = models
        @tools = tools
      end

      def view_template
        view_context.content_for(:title, "New session")

        render Components::Sessions::FormComponent.new(session: @session, custom_agents: @custom_agents, models: @models, tools: @tools)
      end
    end
  end
end
