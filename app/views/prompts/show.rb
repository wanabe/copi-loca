# frozen_string_literal: true

class Views::Prompts::Show < Views::Base
  def initialize(prompt:, notice: nil)
    @prompt = prompt
    @notice = notice
  end

  def view_template
    if @notice
      p(style: "color: green") { @notice }
    end
    render Components::Prompts::Prompt.new(prompt: @prompt)
    div do
      a(href: "/prompts/#{@prompt.id}/edit") { "Edit this prompt" }
      plain " | "
      a(href: "/prompts") { "Back to prompts" }
      br
      form(action: "/prompts/#{@prompt.id}", method: "post") do
        input(type: "hidden", name: "_method", value: "delete")
        button { "Destroy this prompt" }
      end
      form(action: "/prompts/#{@prompt.id}/run", method: "post") do
        button { "Run this prompt" }
      end
    end
  end
end
