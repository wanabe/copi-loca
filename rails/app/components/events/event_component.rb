# frozen_string_literal: true

class Components::Events::EventComponent < Components::Base
  include Phlex::Rails::Helpers::DOMID

  def initialize(event:, mode: nil)
    @event = event
    @mode = mode
  end

  def view_template
    div id: dom_id(@event), class: (@mode == :table ? "events-flex-row" : "event") do
      strong(class: "event-label") { plain "ID:" }
      div(class: "events-col-id") { a(href: session_event_path(@event.session, @event)) { plain @event.id } }

      strong(class: "event-label") { plain "Type:" }
      div(class: "events-col-type") { plain @event.event_type }

      strong(class: "event-label") { plain "Event ID:" }
      div(class: "events-col-eventid") { plain @event.event_id }

      strong(class: "event-label") { plain "Data:" }
      div(class: "events-col-data") { plain(JSON.pretty_generate(@event.data)) }

      strong(class: "event-label") { plain "Timestamp:" }
      div(class: "events-col-timestamp") { plain @event.timestamp.to_s }

      strong(class: "event-label") { plain "Parent:" }
      div(class: "events-col-parent") do
        if @event.parent_event_id
          a(href: session_event_path(@event.session, @event.parent_event_id)) { plain @event.parent_event_id }
        else
          plain ""
        end
      end
    end
  end
end
