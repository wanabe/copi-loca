# frozen_string_literal: true

class Components::Events::ShowComponent < Components::Base
  def initialize(event:)
    @event = event
  end

  def view_template
    render Components::Events::EventComponent.new(event: @event, mode: :single)

    div do
      a(href: session_events_path(@event.session)) { plain "Back to events" }
    end
  end
end
