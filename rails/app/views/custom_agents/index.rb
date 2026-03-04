# frozen_string_literal: true

module Views
  module CustomAgents
    class Index < Components::Base
      def initialize(custom_agents:)
        @custom_agents = custom_agents
      end

      def view_template
        view_context.content_for(:title, "Custom agents")

        render Components::CustomAgents::IndexComponent.new(custom_agents: @custom_agents)
      end
    end
  end
end
