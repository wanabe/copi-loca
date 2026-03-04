# frozen_string_literal: true

module Views
  module CustomAgents
    class Show < Components::Base
      def initialize(custom_agent:)
        @custom_agent = custom_agent
      end

      def view_template
        render Components::CustomAgents::CustomAgentComponent.new(custom_agent: @custom_agent)

        div do
          a(href: edit_custom_agent_path(@custom_agent)) { plain "Edit this custom agent" }
          plain " | "
          a(href: custom_agents_path) { plain "Back to custom agents" }

          # destroy button
          form(action: custom_agent_path(@custom_agent), method: "post") do
            input(type: "hidden", name: "_method", value: "delete")
            input(type: "hidden", name: "authenticity_token", value: view_context.form_authenticity_token)
            button(type: "submit") { plain "Destroy this custom agent" }
          end
        end
      end
    end
  end
end
