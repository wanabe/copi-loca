# frozen_string_literal: true

module Views
  module Files
    class Index < Components::Base
      def initialize(tree:)
        @tree = tree
      end

      def view_template
        h1 { plain "Files in /app" }
        render Components::Files::TreeComponent.new(tree: @tree, path: "")
      end
    end
  end
end
