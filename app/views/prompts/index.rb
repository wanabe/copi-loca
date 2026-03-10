# frozen_string_literal: true

class Views::Prompts::Index < Views::Base
  def initialize(prompts:, notice: nil)
    @prompts = prompts
    @notice = notice
  end

  def view_template
    p(style: "color: green") { @notice } if @notice
    h1 { "Prompts" }
    div(id: "prompts") do
      @prompts.each do |prompt|
        render Components::Prompts::Prompt.new(prompt: prompt)
        p do
          a(href: "/prompts/#{prompt.id}") { "Show this prompt" }
        end
      end
    end
    a(href: "/prompts/new") { "New prompt" }
  end
end
