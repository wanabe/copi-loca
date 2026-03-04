# frozen_string_literal: true

class Views::Operations::Edit < Views::Base
  def initialize(operation:)
    @operation = operation
  end

  def view_template
    view_context.content_for(:title, "Editing operation")

    h1 { plain "Editing operation" }

    render Components::Operations::FormComponent.new(operation: @operation)

    br

    div do
      a(href: operation_path(@operation)) { plain "Show this operation" }
      plain " | "
      a(href: operations_path) { plain "Back to operations" }
    end
  end
end
