# frozen_string_literal: true

class Views::Tools::Show < Components::Base
  def initialize(tool:)
    @tool = tool
  end

  def view_template
    render Components::Tools::ShowComponent.new(tool: @tool)
  end
end
