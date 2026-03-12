# frozen_string_literal: true

class Views::Prompts::Edit < Views::Base
  def initialize(prompt:)
    @prompt = prompt
  end

  def view_template
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
