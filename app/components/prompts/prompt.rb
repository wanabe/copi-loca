# frozen_string_literal: true

class Components::Prompts::Prompt < Components::Base
  def initialize(prompt:)
    @prompt = prompt
  end

  def view_template
    div(id: dom_id(@prompt)) do
      h2 { @prompt.id }
      p(class: "whitespace-break-spaces") { @prompt.text }
      if @prompt.response
        div(class: "border border-gray-300 p-2 mt-2 rounded bg-white shadow-sm") do
          h3 { "Response" }
          p(class: "whitespace-break-spaces") { @prompt.response.text }
        end
      end
    end
  end
end
