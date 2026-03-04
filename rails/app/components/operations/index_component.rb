# frozen_string_literal: true

class Components::Operations::IndexComponent < Components::Base
  def initialize(operations:)
    @operations = operations
  end

  def view_template
    h1 { plain "Operations" }
    div(id: "operations") do
      @operations.each do |operation|
        render Components::Operations::OperationComponent.new(operation: operation)
        p { a(href: operation_path(operation)) { plain "Show this operation" } }
      end
    end

    div { a(href: new_operation_path) { plain "New operation" } }
  end
end
