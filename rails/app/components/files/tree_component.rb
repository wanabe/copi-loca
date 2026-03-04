# frozen_string_literal: true

module Components
  module Files
    class TreeComponent < Components::Base
      def initialize(tree:, path: "")
        @tree = tree
        @path = path
      end

      def view_template
        ul do
          @tree[:dirs]&.sort&.each do |dirname, subtree|
            li do
              details do
                summary do
                  strong { plain "#{dirname}/" }
                end
                render Components::Files::TreeComponent.new(tree: subtree, path: File.join(@path, dirname))
              end
            end
          end

          @tree[:files]&.sort&.each do |filename|
            li { a(href: file_path(File.join(@path, filename).sub(%r{^/}, ""))) { plain filename } }
          end
        end
      end
    end
  end
end
