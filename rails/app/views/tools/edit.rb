# frozen_string_literal: true

class Views::Tools::Edit < Views::Base
  def initialize(tool:)
    @tool = tool
  end

  def view_template
    render Components::Tools::EditComponent.new(tool: @tool)
  end
end
