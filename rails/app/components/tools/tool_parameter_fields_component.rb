# frozen_string_literal: true

module Components
  module Tools
    class ToolParameterFieldsComponent < Components::Base
      def initialize(f_object:, child_index: nil)
        @f_object = f_object
        @child_index = child_index
      end

      def view_template
        # This component renders form fields similar to the original partial which used form builder `f`.
        # For simplicity we produce inputs with names matching Rails nested attributes conventions.
        index = @child_index || @f_object.id || "new"

        div(class: "nested-fields tool-parameter-fields") do
          input(type: "hidden", name: "tool[tool_parameters_attributes][#{index}][_destroy]", value: "false")

          div do
            label { plain "Name" }
            input(type: "text", name: "tool[tool_parameters_attributes][#{index}][name]", value: @f_object.respond_to?(:name) ? @f_object.name : nil)
          end

          div do
            label { plain "Type" }
            input(type: "text", name: "tool[tool_parameters_attributes][#{index}][type]", value: @f_object.respond_to?(:type) ? @f_object.type : nil)
          end

          div do
            label { plain "Default" }
            input(type: "text", name: "tool[tool_parameters_attributes][#{index}][default]",
              value: @f_object.respond_to?(:default) ? @f_object.default : nil)
          end

          a(href: "#", data: { action: "tool-parameters#remove" }) { plain "Remove" }
        end
      end
    end
  end
end
