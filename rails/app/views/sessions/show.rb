# frozen_string_literal: true

class Views::Sessions::Show < Components::Base
  include Phlex::Rails::Helpers::TurboStreamFrom

  def initialize(session:, display_state:, job_status: :idle)
    @session = session
    @display_state = display_state
    @job_status = job_status
  end

  def view_template
    render Components::Messages::FormComponent.new(session: @session, message: @session.messages.new, from: "session_show",
      display_state: @display_state, job_status: @job_status)
    turbo_stream_from([@session, :stream])
    render Components::Sessions::SessionComponent.new(session: @session, display_state: @display_state, job_status: @job_status)
  end
end
