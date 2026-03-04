# frozen_string_literal: true

class Views::Operations::Show < Components::Base
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::TurboStreamFrom
  include Phlex::Rails::Helpers::ButtonTo

  def initialize(operation:, status: nil, output: nil)
    @operation = operation
    @status = status
    @output = output
  end

  def view_template
    render Components::Operations::OperationComponent.new(operation: @operation)

    div do
      link_to("Edit this operation", edit_operation_path(@operation))
      plain " | "
      link_to("Back to operations", operations_path)
      turbo_stream_from(@operation) if @operation.background?
      render Components::Operations::RunComponent.new(operation: @operation, status: @status, output: @output)

      hr

      button_to("Destroy this operation", @operation, method: :delete,
        data: { turbo_confirm: "Are you sure you want to destroy this operation?" })
    end
  end
end
