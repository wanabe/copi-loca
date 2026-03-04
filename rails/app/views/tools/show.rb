# frozen_string_literal: true

class Views::Tools::Show < Views::Base
  def initialize(tool:)
    @tool = tool
  end

  def view_template
    render Components::Tools::ShowComponent.new(tool: @tool)
  end
end
