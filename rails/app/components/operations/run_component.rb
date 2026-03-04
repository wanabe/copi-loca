# frozen_string_literal: true

class Components::Operations::RunComponent < Components::Base
  include Phlex::Rails::Helpers::TurboFrameTag
  include Phlex::Rails::Helpers::FormAuthenticityToken

  def initialize(operation:, status:, output:)
    @operation = operation
    @status = status
    @output = output
  end

  def view_template
    div(id: "operation-result") do
      turbo_frame_tag("result") do
        form(action: run_operation_path(@operation), method: :post) do
          input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
          button(type: "submit") { plain "Run this operation" }
        end
        p do
          strong { plain "Exit status:" }
          plain " "
          plain @status.to_s
        end
        pre(class: "operations-run__output") { plain @output.to_s }
      end
    end
  end
end
