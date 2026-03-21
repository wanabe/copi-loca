# frozen_string_literal: true
# rbs_inline: enabled

class Views::Prompts::New < Views::Base
  # @rbs @prompt: Prompt

  # @rbs prompt: Prompt
  # @rbs return: void
  def initialize(prompt:)
    @prompt = prompt
  end

  # @rbs return: void
  def view_template
    h1(class: "text-2xl font-bold mb-4") { "New prompt" }
    render Components::Prompts::Form.new(prompt: @prompt)
    br
    div do
      link_to "Back to prompts", prompts_path
    end
  end
end
