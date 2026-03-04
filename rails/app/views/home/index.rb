# frozen_string_literal: true

module Views
  module Home
    class Index < Views::Base
      include Phlex::Rails::Helpers::Routes

      def view_template
        h1 { plain "Copi Loca" }
        h2 { plain "Main" }
        ul do
          li { a(href: sessions_path) { plain "Sessions" } }
        end

        h2 { plain "Copilot support" }
        ul do
          li { a(href: models_path) { plain "Models" } }
          li { a(href: tools_path) { plain "Tools" } }
          li { a(href: custom_agents_path) { plain "Custom Agents" } }
        end

        h2 { plain "Development" }
        ul do
          li { a(href: files_path) { plain "Files" } }
          li { a(href: changes_path) { plain "Changes" } }
          li { a(href: operations_path) { plain "Operations" } }
        end
      end
    end
  end
end
