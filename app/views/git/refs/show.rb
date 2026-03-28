# frozen_string_literal: true
# rbs_inline: enabled

class Views::Git::Refs::Show < Views::Base
  # @rbs @ref: String
  # @rbs @flash: Hash[Symbol, String]
  # @rbs @breadcrumbs: Array[Breadcrumb]

  # @rbs ref: String
  # @rbs flash: Hash[Symbol, String]
  # @rbs breadcrumbs: Array[Breadcrumb]
  # @rbs return: void
  def initialize(ref:, flash: {}, breadcrumbs: [])
    super(flash: flash, breadcrumbs: breadcrumbs)
    @ref = ref
  end

  # @rbs return: void
  def body_template
    h1(class: "text-2xl font-bold mb-4") { "Git Ref: #{@ref}" }
    render Components::Git::RefCommands.new(ref: @ref)
  end
end
