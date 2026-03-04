# frozen_string_literal: true

module Views
  module Operations
    class New < Components::Base
      def initialize(operation:)
        @operation = operation
      end

      def view_template
        view_context.content_for(:title, "New operation")

        h1 { plain "New operation" }

        render Components::Operations::FormComponent.new(operation: @operation)

        br

        div do
          a(href: operations_path) { plain "Back to operations" }
        end
      end
    end
  end
end
