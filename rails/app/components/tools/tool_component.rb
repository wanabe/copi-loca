# frozen_string_literal: true

class Components::Tools::ToolComponent < Components::Base
  include Phlex::Rails::Helpers::DOMID

  def initialize(tool:)
    @tool = tool
  end

  def view_template
    div id: dom_id(@tool) do
      div do
        strong { plain "Name:" }
        plain " "
        plain @tool.name
      end

      div do
        strong { plain "Description:" }
        plain " "
        plain @tool.description
      end

      div do
        strong { plain "Script:" }
        plain " "
        plain @tool.script
      end
    end
  end
end
