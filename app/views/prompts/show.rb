# frozen_string_literal: true

class Views::Prompts::Show < Views::Base
  def initialize(prompt:, notice: nil)
    @prompt = prompt
    @notice = notice
  end

  def view_template
    p(class: "text-green-600 mb-4") { @notice } if @notice
    render Components::Prompts::Prompt.new(prompt: @prompt)
    div(class: "space-y-4 mt-6") do
      link_to "Edit this prompt", edit_prompt_path(@prompt), class: "text-blue-600 hover:underline mr-2"
      plain " | "
      link_to "Back to prompts", prompts_path, class: "text-gray-600 hover:underline ml-2"
      br
      form(action: "/prompts/#{@prompt.id}", method: "post", class: "inline") do
        input(type: "hidden", name: "_method", value: "delete")
        button(class: "bg-red-500 text-white px-3 py-1 rounded hover:bg-red-600") { "Destroy this prompt" }
      end
      form(action: "/prompts/#{@prompt.id}/run", method: "post", class: "inline ml-4") do
        button(class: "bg-green-500 text-white px-3 py-1 rounded hover:bg-green-600") { "Run this prompt" }
      end
    end
  end
end
