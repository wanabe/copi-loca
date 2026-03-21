# frozen_string_literal: true
# rbs_inline: enabled

class Components::Bin::Run < Components::Base
  # @rbs status: Integer?
  # @rbs output: String?
  # @rbs return: void
  def initialize(status:, output:)
    # @rbs @status: Integer?

    @status = status

    # @rbs @output: String?

    @output = output
  end

  # @rbs return: void
  def view_template
    turbo_frame_tag("bin-run-result") do
      if @status
        h2(class: "text-xl font-bold mb-2") { "Run status" }
        p(class: "bg-gray-100 p-4 rounded") { @status }
      end
      if @output
        h2(class: "text-xl font-bold mb-2") { "Run result" }
        pre(class: "bg-gray-100 p-4 rounded") { @output }
      end
    end
  end
end
