# frozen_string_literal: true

class Components::Prompts::Form < Components::Base
  def initialize(prompt:)
    @prompt = prompt
  end

  def view_template
    form_with(model: @prompt) do |form|
      if @prompt.errors.any?
        div(class: "text-red-600 mb-4") do
          h2 { "#{pluralize(@prompt.errors.count, 'error')} prohibited this prompt from being saved:" }
          ul do
            @prompt.errors.each do |error|
              li { error.full_message }
            end
          end
        end
      end
      div(class: "mb-4") do
        form.label(:id, class: "block text-gray-700 font-bold mb-2")
        form.text_field(:id,
          class: "shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline")
      end
      div(class: "mb-4") do
        form.label(:name, class: "block text-gray-700 font-bold mb-2")
        form.text_field(:name,
          class: "shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline")
      end
      div(class: "mb-4") do
        form.label(:description, class: "block text-gray-700 font-bold mb-2")
        form.text_field(:description,
          class: "shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline")
      end
      div(class: "mb-4") do
        form.label(:text, class: "block text-gray-700 font-bold mb-2")
        form.text_area(:text,
          class: "shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline")
      end
      div(class: "flex justify-end") do
        form.submit(class: "bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline")
      end
    end
  end
end
