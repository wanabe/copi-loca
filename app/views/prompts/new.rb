# frozen_string_literal: true

class Views::Prompts::New < Views::Base
  def initialize(prompt:)
    @prompt = prompt
  end

  def view_template
    h1(class: "text-2xl font-bold mb-4") { "New prompt" }
    render Components::Prompts::Form.new(prompt: @prompt)
    br
    div do
      link_to "Back to prompts", prompts_path
    end
  end
end
