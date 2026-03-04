# frozen_string_literal: true

require "rails_helper"

RSpec.describe Components::Messages::FormComponent, type: :component do
  it "renders custom_agents select when present" do
    session = Session.new(id: "dummy", custom_agents: [CustomAgent.new(id: 1, name: "agent")])
    message = Message.new
    render described_class.new(session: session, message: message)
    expect(rendered).to include("custom_agent_id")
    expect(rendered).to include("@agent")
  end
end
