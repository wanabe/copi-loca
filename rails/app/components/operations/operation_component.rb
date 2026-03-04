# frozen_string_literal: true

class Components::Operations::OperationComponent < Components::Base
  include Phlex::Rails::Helpers::DOMID

  def initialize(operation:)
    @operation = operation
  end

  def view_template
    div id: dom_id(@operation) do
      div do
        strong { plain "Command:" }
        plain " "
        plain @operation.command
      end

      div do
        strong { plain "Directory:" }
        plain " "
        plain @operation.directory
      end

      div do
        strong { plain "Execution timing:" }
        plain " "
        plain @operation.execution_timing.to_s.humanize
      end
    end
  end
end
