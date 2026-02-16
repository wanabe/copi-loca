class EventsController < ApplicationController
  include SessionRelated

  before_action :set_session
  before_action :set_event, only: %i[ show ]
  before_action :add_sessions_breadcrumb
  before_action :add_session_breadcrumb
  before_action :add_events_breadcrumb
  before_action :add_event_breadcrumb, only: %i[ show ]

  # GET /events
  def index
    @types = @session.events.distinct.pluck(:event_type).compact.sort || []
    @selected_types = Array(params[:types])
    scope = @session.events
    scope = scope.where(event_type: @selected_types) if @selected_types.present?
    @events = scope.order(id: :desc).page(params[:page])
  end

  # GET /events/1
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    def add_events_breadcrumb
      add_breadcrumb("Events", session_events_path(@session))
    end

    def add_event_breadcrumb
      add_breadcrumb(@event.id, session_event_path(@session, @event))
    end
end
