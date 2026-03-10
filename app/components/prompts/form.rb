# frozen_string_literal: true

class Components::Prompts::Form < Components::Base
  def initialize(prompt:)
    @prompt = prompt
  end

  def view_template
    form_with(model: @prompt) do |form|
      if @prompt.errors.any?
        div(style: "color: red") do
          h2 { "#{pluralize(@prompt.errors.count, 'error')} prohibited this prompt from being saved:" }
          ul do
            @prompt.errors.each do |error|
              li { error.full_message }
            end
          end
        end
      end
      div do
        form.label(:id)
        br
        form.text_field(:id)
      end
      div do
        form.label(:text)
        br
        form.text_area(:text)
      end
      div do
        form.submit
      end
    end
  end
end
