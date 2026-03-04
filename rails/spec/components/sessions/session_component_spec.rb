# frozen_string_literal: true

require "rails_helper"

RSpec.describe Components::Sessions::SessionComponent do
  it "renders when show_messages is true" do
    session = Session.new(id: "dummy")
    render described_class.new(session: session, display_state: { "show_messages" => "true" }, job_status: :running)
    expect(rendered).to include("Messages")
  end
end
