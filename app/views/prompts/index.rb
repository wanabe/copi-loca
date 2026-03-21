# frozen_string_literal: true
# rbs_inline: enabled

class Views::Prompts::Index < Views::Base
  # @rbs @prompts: Kaminari::PaginatableArray[Prompt]
  # @rbs @notice: String?

  # @rbs prompts: Kaminari::PaginatableArray[Prompt]
  # @rbs notice: String?
  # @rbs return: void
  def initialize(prompts:, notice: nil)
    @prompts = prompts
    @notice = notice
  end

  # @rbs return: void
  def view_template
    p(class: "text-green-600 mb-4") { @notice } if @notice
    h1(class: "text-2xl font-bold mb-4") { "Prompts" }
    table(id: "prompts", class: "space-y-4") do
      thead do
        tr do
          th(class: "text-left font-semibold") { "ID" }
          th(class: "text-left font-semibold") { "PID" }
          th(class: "text-left font-semibold") { "Name" }
          th(class: "text-left font-semibold") { "Description" }
          th(class: "text-left font-semibold") { "Text" }
          th(class: "text-left font-semibold") { "Response" }
        end
      end
      tbody do
        @prompts.each do |prompt|
          tr do
            td(class: "border px-4 py-2") { link_to prompt.id.to_s, prompt_path(prompt) }
            td(class: "border px-4 py-2") { prompt.pid }
            td(class: "border px-4 py-2") { prompt.name }
            td(class: "border px-4 py-2") { short(prompt.description) }
            td(class: "border px-4 py-2") { short(prompt.text) }
            td(class: "border px-4 py-2") { short(prompt.response&.text) }
          end
        end
      end
    end
    br
    render Components::Paginator.new(items: @prompts)
    link_to "New prompt", new_prompt_path, class: "inline-block mt-6 bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
  end

  private

  # @rbs text: String?
  # @rbs limit: Integer
  # @rbs return: String?
  def short(text, limit: 20)
    return if text.blank?

    text =~ /\A(.{,#{limit}})(\n|.)?/
    result = ::Regexp.last_match(1)
    rest = ::Regexp.last_match(2)
    result += " ..." if result && rest
    result
  end
end
