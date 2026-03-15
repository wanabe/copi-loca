# frozen_string_literal: true

class Components::Prompts::Prompt < Components::Base
  def initialize(prompt:)
    @prompt = prompt
  end

  def view_template
    div(id: dom_id(@prompt)) do
      h2(class: "text-xl font-bold") { @prompt.id }
      p(class: "text-gray-600 italic") { "PID: #{@prompt.pid}" }
      h3(class: "text-lg font-semibold") { @prompt.name } if @prompt.name
      p(class: "text-gray-600 italic") { @prompt.description } if @prompt.description
      p(class: "whitespace-break-spaces") { @prompt.text }
      if @prompt.response
        div(class: "border border-gray-300 p-2 mt-2 rounded bg-white shadow-sm") do
          h3(class: "text-lg font-semibold") { "Response" }
          p(class: "whitespace-break-spaces") { @prompt.response.text }
        end
      end
    end
  end
end
