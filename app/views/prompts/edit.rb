# frozen_string_literal: true

class Views::Prompts::Edit < Views::Base
  def initialize(prompt:)
    @prompt = prompt
  end

  def view_template
    content_for :title, "Editing prompt"
    h1 { "Editing prompt" }
    render Components::Prompts::Form.new(prompt: @prompt)
    br
    div do
      a(href: "/prompts/#{@prompt.id}") { "Show this prompt" }
      plain " | "
      a(href: "/prompts") { "Back to prompts" }
    end
  end
end
