# frozen_string_literal: true
# rbs_inline: enabled

class Components::Bin::Bin < Components::Base
  # @rbs @bin: Bin

  # @rbs bin: Bin
  # @rbs return: void
  def initialize(bin:)
    @bin = bin
  end

  # @rbs return: void
  def view_template
    div(id: dom_id(@bin)) do
      h2(class: "text-xl font-bold") { @bin.id }
    end
  end
end
