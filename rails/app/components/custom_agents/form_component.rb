# frozen_string_literal: true

module Components
  module CustomAgents
    class FormComponent < Components::Base
      include Phlex::Rails::Helpers::FormAuthenticityToken
      include Phlex::Rails::Helpers::Pluralize

      def initialize(custom_agent:)
        @custom_agent = custom_agent
      end

      def view_template
        form(action: polymorphic_path([@custom_agent]), method: (@custom_agent.persisted? ? "patch" : "post")) do
          input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)

          if @custom_agent.respond_to?(:errors) && @custom_agent.errors.any?
            div(class: "custom-agents-form__errors") do
              h2 { plain "#{pluralize(@custom_agent.errors.count, 'error')} prohibited this custom_agent from being saved:" }
              ul do
                @custom_agent.errors.each do |error|
                  li { plain error.full_message }
                end
              end
            end
          end

          div do
            label(for: "custom_agent_name", style: "display: block") { plain "Name" }
            input(type: "text", name: "custom_agent[name]", id: "custom_agent_name", value: @custom_agent.name)
          end

          div do
            label(for: "custom_agent_display_name", style: "display: block") { plain "Display name" }
            input(type: "text", name: "custom_agent[display_name]", id: "custom_agent_display_name", value: @custom_agent.display_name)
          end

          div do
            label(for: "custom_agent_description", style: "display: block") { plain "Description" }
            textarea(name: "custom_agent[description]", id: "custom_agent_description") { plain @custom_agent.description.to_s }
          end

          div do
            label(for: "custom_agent_prompt", style: "display: block") { plain "Prompt" }
            textarea(name: "custom_agent[prompt]", id: "custom_agent_prompt") { plain @custom_agent.prompt.to_s }
          end

          div do
            button(type: "submit") { plain(@custom_agent.persisted? ? "Update Custom agent" : "Create Custom agent") }
          end
        end
      end
    end
  end
end
