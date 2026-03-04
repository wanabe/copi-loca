# frozen_string_literal: true

class Views::Tools::Index < Views::Base
  def initialize(tools:)
    @tools = tools
  end

  def view_template
    content_for(:title, "Tools")
    h1 { plain "Tools" }
    div(id: "tools") do
      @tools.each do |tool|
        render Components::Tools::ToolComponent.new(tool: tool)
        p { a(href: tool_path(tool)) { plain "Show this tool" } }
      end
    end

    div { a(href: new_tool_path) { plain "New tool" } }
  end
end
