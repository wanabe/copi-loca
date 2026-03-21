# frozen_string_literal: true
# rbs_inline: enabled

class Views::Ps::Index < Views::Base
  # @rbs @lines: Array[String]

  # @rbs lines: Array[String]
  # @rbs return: void
  def initialize(lines:)
    @lines = lines
  end

  # @rbs return: void
  def view_template
    h1(class: "text-2xl font-bold mb-4") { "Ps" }
    div(id: "ps", class: "space-y-2") do
      @lines.each do |line|
        p(class: "text-base text-gray-700 bg-gray-100 rounded px-3 py-2") { line }
      end
    end
  end
end
