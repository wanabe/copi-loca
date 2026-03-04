# frozen_string_literal: true

class Views::Events::Show < Views::Base
  def initialize(event:)
    @event = event
  end

  def view_template
    render Components::Events::ShowComponent.new(event: @event)
  end
end
