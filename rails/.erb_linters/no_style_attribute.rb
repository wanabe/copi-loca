# .erb-linters/no_style_attribute.rb
require 'erb_lint/linter'
require 'better_html/tree/tag'

module ERBLint
  module Linters
    class NoStyleAttribute < Linter
      include LinterRegistry

      def run(processed_source)
        processed_source.ast.descendants(:tag).each do |tag_node|
          tag = BetterHtml::Tree::Tag.from_node(tag_node)
          style_attribute = tag.attributes['style']

          if style_attribute
            add_offense(
              style_attribute.loc,
              "Inline `style=#{style_attribute.value}` is not allowed. Please use CSS classes instead."
            )
          end
        end
      end
    end
  end
end
