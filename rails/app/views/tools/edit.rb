# frozen_string_literal: true

class Views::Tools::Edit < Views::Base
  def initialize(tool:)
    @tool = tool
  end

  def view_template
    h1 { plain "Edit tool" }
    render Components::Tools::FormComponent.new(tool: @tool)

    div do
      a(href: tools_path) { plain "Back" }
    end
  end
end
