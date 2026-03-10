# frozen_string_literal: true

class Components::Prompts::Prompt < Components::Base
  def initialize(prompt:)
    @prompt = prompt
  end

  def view_template
    div(id: dom_id(@prompt)) do
      h2 { @prompt.id }
      p { @prompt.text }
      if @prompt.response
        div(style: "border: 1px solid #ccc; padding: 10px; margin-top: 10px;") do
          h3 { "Response" }
          p { @prompt.response.text }
        end
      end
    end
  end
end
