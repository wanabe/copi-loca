# frozen_string_literal: true

class Views::Operations::Index < Components::Base
  def initialize(operations:)
    @operations = operations
  end

  def view_template
    view_context.content_for(:title, "Operations")

    render Components::Operations::IndexComponent.new(operations: @operations)
  end
end
