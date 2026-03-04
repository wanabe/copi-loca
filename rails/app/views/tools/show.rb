# frozen_string_literal: true

class Views::Tools::Show < Views::Base
  def initialize(tool:)
    @tool = tool
  end

  def view_template
    h1 { plain @tool.name }

    div(class: "tool__content") do
      plain @tool.description.to_s
    end

    div(class: "tool__actions") do
      a(href: edit_tool_path(@tool)) { plain "Edit" }
      form(action: tool_path(@tool), method: "post", style: "display:inline") do
        input(type: "hidden", name: "_method", value: "delete")
        input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
        button(type: "submit") { plain "Delete" }
      end
    end
  end
end
