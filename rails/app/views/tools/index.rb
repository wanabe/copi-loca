# frozen_string_literal: true

module Views
  module Tools
    class Index < Components::Base
      def initialize(tools:)
        @tools = tools
      end

      def view_template
        view_context.content_for(:title, "Tools")

        render Components::Tools::IndexComponent.new(tools: @tools)
      end
    end
  end
end
