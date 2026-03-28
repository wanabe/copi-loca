# frozen_string_literal: true
# rbs_inline: enabled

class Views::Prompts::Edit < Views::Base
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
    content_for :title, "Editing prompt"
    h1(class: "text-2xl font-bold mb-4") { "Editing prompt" }
    render Components::Prompts::Form.new(prompt: @prompt)
    div do
      link_to "Show this prompt", "/prompts/#{@prompt.id}", class: "text-blue-600 hover:underline"
      plain " | "
      link_to "Back to prompts", "/prompts", class: "text-gray-600 hover:underline"
    end
  end
end
