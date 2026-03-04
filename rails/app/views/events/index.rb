# frozen_string_literal: true

module Views
  module Events
    class Index < Components::Base
      def initialize(session:, types:, selected_types:, events:, limit: 10)
        @session = session
        @types = types
        @selected_types = selected_types
        @events = events
        @limit = limit
      end

      def view_template
        view_context.content_for(:title, "Events")

        h1 { plain "Events" }

        form(action: session_events_path(@session), method: "get") do
          div do
            strong { plain "Filter by type:" }
            br
            @types.each do |type|
              label do
                input(type: "checkbox", name: "types[]", value: type, id: "type_#{type}", checked: @selected_types.include?(type))
                plain " "
                plain type.to_s
              end
            end
          end

          div do
            button(type: "submit") { plain "Show" }
          end
        end

        render Components::Events::EventsComponent.new(events: @events, limit: @limit)
        render Components::Pagination::PaginationComponent.new(collection: @events)
      end
    end
  end
end
