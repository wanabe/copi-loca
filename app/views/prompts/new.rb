# frozen_string_literal: true
# rbs_inline: enabled

class Views::Prompts::New < Views::Base
  # @rbs @prompt: Prompt
  # @rbs @flash: Hash[Symbol, String]
  # @rbs @breadcrumbs: Array[Breadcrumb]

  # @rbs prompt: Prompt
  # @rbs flash: Hash[Symbol, String]
  # @rbs breadcrumbs: Array[Breadcrumb]
  # @rbs return: void
  def initialize(prompt:, flash: {}, breadcrumbs: [])
    super(flash: flash, breadcrumbs: breadcrumbs)
    @prompt = prompt
  end

  # @rbs return: void
  def body_template
    h1(class: "text-2xl font-bold mb-4") { "New prompt" }
    render Components::Prompts::Form.new(prompt: @prompt)
    br
    div do
      link_to "Back to prompts", prompts_path
    end
  end
end
