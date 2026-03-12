# frozen_string_literal: true

class Views::Prompts::Index < Views::Base
  def initialize(prompts:, notice: nil)
    @prompts = prompts
    @notice = notice
  end

  def view_template
    p(class: "text-green-600 mb-4") { @notice } if @notice
    h1(class: "text-2xl font-bold mb-4") { "Prompts" }
    div(id: "prompts", class: "space-y-4") do
      @prompts.each do |prompt|
        render Components::Prompts::Prompt.new(prompt: prompt)
        p(class: "mt-2") do
          a(href: "/prompts/#{prompt.id}", class: "text-blue-500 hover:underline") { "Show this prompt" }
        end
      end
    end
    render Components::Paginator.new(items: @prompts)
    a(href: "/prompts/new", class: "inline-block mt-6 bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded") { "New prompt" }
  end
end
