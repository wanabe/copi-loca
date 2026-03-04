# frozen_string_literal: true

module Views
  module Events
    class Show < Components::Base
      def initialize(event:)
        @event = event
      end

      def view_template
        render Components::Events::ShowComponent.new(event: @event)
      end
    end
  end
end
