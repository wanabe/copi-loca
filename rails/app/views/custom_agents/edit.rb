# frozen_string_literal: true

module Views
  module CustomAgents
    class Edit < Components::Base
      def initialize(custom_agent:)
        @custom_agent = custom_agent
      end

      def view_template
        view_context.content_for(:title, "Editing custom agent")

        h1 { plain "Editing custom agent" }

        render Components::CustomAgents::FormComponent.new(custom_agent: @custom_agent)

        br

        div do
          a(href: custom_agent_path(@custom_agent)) { plain "Show this custom agent" }
          plain " | "
          a(href: custom_agents_path) { plain "Back to custom agents" }
        end
      end
    end
  end
end
