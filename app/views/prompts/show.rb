# frozen_string_literal: true
# rbs_inline: enabled

class Views::Prompts::Show < Views::Base
  # @rbs @prompt: Prompt

  # @rbs prompt: Prompt
  # @rbs return: void
  def initialize(prompt:)
    @prompt = prompt
  end

  # @rbs return: void
  def view_template
    render Components::Prompts::Prompt.new(prompt: @prompt)
    div(class: "space-y-4 mt-6") do
      link_to "Edit this prompt", edit_prompt_path(@prompt), class: "text-blue-600 hover:underline mr-2"
      plain " | "
      link_to "Back to prompts", prompts_path, class: "text-gray-600 hover:underline ml-2"
      br
      div(class: "mt-4") do
        form(action: "/prompts/#{@prompt.id}", method: "post", class: "inline") do
          input(type: "hidden", name: "_method", value: "delete")
          button(class: "bg-red-500 text-white px-3 py-1 rounded hover:bg-red-600") { "Destroy this prompt" }
        end
      end
      div(class: "mt-4") do
        form(action: "/prompts/#{@prompt.id}/run", method: "post", class: "inline ml-4") do
          button(class: "bg-green-500 text-white px-3 py-1 rounded hover:bg-green-600") { "Run this prompt" }
          input(type: "text", name: "n", value: "1", class: "w-16 inline-block mr-2")
          span { "times" }
        end
      end
    end
  end
end
