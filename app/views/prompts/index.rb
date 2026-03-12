# frozen_string_literal: true

class Views::Prompts::Index < Views::Base
  def initialize(prompts:, notice: nil)
    @prompts = prompts
    @notice = notice
  end

  def view_template
    p(class: "text-green-600 mb-4") { @notice } if @notice
    h1(class: "text-2xl font-bold mb-4") { "Prompts" }
    table(id: "prompts", class: "space-y-4") do
      thead do
        tr do
          th(class: "text-left font-semibold") { "ID" }
          th(class: "text-left font-semibold") { "Text" }
          th(class: "text-left font-semibold") { "Response" }
        end
      end
      tbody do
        @prompts.each do |prompt|
          tr do
            td(class: "border px-4 py-2") { link_to prompt.id, prompt_path(prompt) }
            td(class: "border px-4 py-2") { short(prompt.text) }
            td(class: "border px-4 py-2") { short(prompt.response&.text) }
          end
        end
      end
    end
    br
    render Components::Paginator.new(items: @prompts)
    a(href: "/prompts/new", class: "inline-block mt-6 bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded") { "New prompt" }
  end

  private

  def short(text, limit: 20)
    return if text.blank?
    text =~ /\A(.{,#{limit}})(\n|.)?/
    result = $1
    rest = $2
    if rest
      result += " ..."
    end
    result
  end
end
