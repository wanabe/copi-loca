require 'rails_helper'

RSpec.describe "events/index", type: :view do
  let(:session) { Session.create!(model: "Model") }
  before(:each) do
    assign(:events, [
      Event.create!(
        session: session,
        event_type: "type1",
        event_id: "event1",
        data: "{\"key\": \"value1\"}",
        ephemeral: false
      ),
      Event.create!(
        session: session,
        event_type: "type2",
        event_id: "event2",
        data: "{\"key\": \"value2\"}",
        ephemeral: false
      )
    ])
  end

  it "renders a list of events" do
    render
    cell_selector = 'div#events>div>div'
    elements = css_select(cell_selector).to_a
    texts = elements.map(&:text)
    expect(texts.map { _1[/Session:\s*(.*)/, 1] }.compact).to eq([session.id] * 2)
    expect(texts.map { _1[/Event type:\s*(.*)/, 1] }.compact).to eq(["type1", "type2"])
  end
end
