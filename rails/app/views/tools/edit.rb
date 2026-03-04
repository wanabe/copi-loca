# frozen_string_literal: true

module Views
  module Tools
    class Edit < Components::Base
      def initialize(tool:)
        @tool = tool
      end

      def view_template
        render Components::Tools::EditComponent.new(tool: @tool)
      end
    end
  end
end
