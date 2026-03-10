# frozen_string_literal: true

class Views::Prompts::New < Views::Base
  def initialize(prompt:)
    @prompt = prompt
  end

  def view_template
    h1 { "New prompt" }
    render Components::Prompts::Form.new(prompt: @prompt)
    br
    div do
      a(href: "/prompts") { "Back to prompts" }
    end
  end
end
