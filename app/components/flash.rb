# frozen_string_literal: true
# rbs_inline: enabled

class Components::Flash < Components::Base
  # @rbs @type: Symbol
  # @rbs @message: String

  # @rbs type: Symbol
  # @rbs message: String
  # @rbs return: void
  def initialize(type:, message:)
    @type = type
    @message = message
  end

  # @rbs return: void
  def view_template
    div(class: "mb-4 px-4 py-3 rounded whitespace-pre-line #{alert_class(@type)}", role: "alert") do
      @message
    end
  end

  private

  # @rbs type: Symbol
  # @rbs return: String
  def alert_class(type)
    case type.to_sym
    when :notice
      "bg-green-100 text-green-800"
    when :alert
      "bg-red-100 text-red-800"
    else
      "bg-gray-100 text-gray-800"
    end
  end
end
