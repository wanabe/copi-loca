# frozen_string_literal: true

class Views::Tools::New < Components::Base
  include Phlex::Rails::Helpers::LinkTo

  def initialize(tool:)
    @tool = tool
  end

  def view_template
    view_context.content_for(:title, "New tool")

    h1 { plain "New tool" }

    render Components::Tools::FormComponent.new(tool: @tool)

    br

    div do
      link_to("Back to tools", tools_path)
    end
  end
end
