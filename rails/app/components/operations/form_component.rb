# frozen_string_literal: true

module Components
  module Operations
    class FormComponent < Components::Base
      include Phlex::Rails::Helpers::FormAuthenticityToken
      include Phlex::Rails::Helpers::Pluralize

      def initialize(operation:)
        @operation = operation
      end

      def view_template
        form(action: polymorphic_path([@operation]), method: (@operation.persisted? ? "patch" : "post")) do
          input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)

          if @operation.respond_to?(:errors) && @operation.errors.any?
            div(class: "operations-form__errors") do
              h2 { plain "#{pluralize(@operation.errors.count, 'error')} prohibited this operation from being saved:" }
              ul do
                @operation.errors.each do |error|
                  li { plain error.full_message }
                end
              end
            end
          end

          div do
            label(for: "operation_command", style: "display: block") { plain "Command" }
            input(type: "text", name: "operation[command]", id: "operation_command", value: @operation.command)
          end

          div do
            label(for: "operation_directory", style: "display: block") { plain "Directory" }
            input(type: "text", name: "operation[directory]", id: "operation_directory", value: @operation.directory)
          end

          div do
            label(for: "operation_execution_timing", style: "display: block") { plain "Execution timing" }
            select(name: "operation[execution_timing]", id: "operation_execution_timing") do
              Operation.execution_timings.each_key do |k|
                option(value: k, selected: (k.to_s == @operation.execution_timing.to_s)) { plain k.humanize }
              end
            end
          end

          div do
            button(type: "submit") { plain(@operation.persisted? ? "Update Operation" : "Create Operation") }
          end
        end
      end
    end
  end
end
