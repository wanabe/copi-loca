# frozen_string_literal: true

class Components::Events::EventsComponent < Components::Base
  def initialize(events:, limit: nil)
    @events = events
    @limit = limit
  end

  def view_template
    div(class: "events-flex-table", id: (@limit == 5 ? "latest_5_events" : "events")) do
      div(class: "events-flex-row events-flex-header") do
        div(class: "events-col-id") { plain "ID" }
        div(class: "events-col-type") { plain "Event type" }
        div(class: "events-col-eventid") { plain "Event ID" }
        div(class: "events-col-data") { plain "Data" }
        div(class: "events-col-timestamp") { plain "Timestamp" }
        div(class: "events-col-parent") { plain "Parent" }
      end

      div(class: "events-flex-body") do
        @events.each do |event|
          render Components::Events::EventComponent.new(event: event, mode: :table)
        end
      end
    end
  end
end
