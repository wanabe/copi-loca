# frozen_string_literal: true
# rbs_inline: enabled

class Views::Bin::Show < Views::Base
  # @rbs @bin: Bin
  # @rbs @flash: Hash[Symbol, String]
  # @rbs @breadcrumbs: Array[Breadcrumb]

  # @rbs bin: Bin
  # @rbs flash: Hash[Symbol, String]
  # @rbs breadcrumbs: Array[Breadcrumb]
  # @rbs return: void
  def initialize(bin:, flash: {}, breadcrumbs: [])
    super(flash: flash, breadcrumbs: breadcrumbs)
    @bin = bin
  end

  # @rbs return: void
  def body_template
    render Components::Bin::Bin.new(bin: @bin)
    form(action: run_bin_path(@bin), method: "post", class: "inline mt-4", data: { turbo_frame: "bin-run-result" }) do
      button(class: "bg-green-500 text-white px-3 py-1 rounded hover:bg-green-600", data: { turbo_action: "replace" }) { "Run this bin" }
    end
    turbo_frame_tag("bin-run-result")
    div(class: "space-y-4 mt-6") do
      link_to "Back to bins", bin_index_path, class: "text-gray-600 hover:underline ml-2"
    end
  end
end
