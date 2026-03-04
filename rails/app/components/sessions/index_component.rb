# frozen_string_literal: true

module Components
  module Sessions
    class IndexComponent < Components::Base
      def initialize(sessions:)
        @sessions = sessions
      end

      def view_template
        table(id: "sessions") do
          thead do
            tr do
              th { plain "id" }
              th { plain "Model" }
              th { plain "links" }
            end
          end

          tbody do
            @sessions.each do |session|
              render Components::Sessions::TableRowComponent.new(session: session)
            end
          end
        end

        div do
          a(href: new_session_path) { plain "New session" }
        end
      end
    end
  end
end
