require 'rails_helper'

RSpec.describe "events/show", type: :view do
  before(:each) do
    session = Session.create!(
      id: "Id",
      model: "Model",
    )
    assign(:event, Event.create!(
      session: session,
      event_type: "Event Type",
      event_id: "Id",
      data: "",
      ephemeral: false
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Event Type/)
    expect(rendered).to match(/Id/)
    expect(rendered).to match(//)
    expect(rendered).to match(/Parent/)
    expect(rendered).to match(/false/)
  end
end
