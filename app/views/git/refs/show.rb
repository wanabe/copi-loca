# frozen_string_literal: true
# rbs_inline: enabled

class Views::Git::Refs::Show < Views::Base
  # @rbs @ref: String

  # @rbs ref: String
  # @rbs return: void
  def initialize(ref:)
    @ref = ref
  end

  # @rbs return: void
  def view_template
    h1(class: "text-2xl font-bold mb-4") { "Git Ref: #{@ref}" }
    render Components::Git::RefCommands.new(ref: @ref)
  end
end
