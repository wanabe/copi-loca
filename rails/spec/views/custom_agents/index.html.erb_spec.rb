# frozen_string_literal: true

require "rails_helper"

RSpec.describe "custom_agents/index", type: :view do
  before do
    assign(:custom_agents, [
      CustomAgent.create!(
        name: "Name",
        description: "MyText",
        prompt: "MyText",
        display_name: "Display Name"
      ),
      CustomAgent.create!(
        name: "Name",
        description: "MyText",
        prompt: "MyText",
        display_name: "Display Name"
      )
    ])
  end

  it "renders a list of custom_agents" do
    render
    cell_selector = "div#custom_agents>div"
    assert_select cell_selector, text: Regexp.new("Name"), count: 2
    assert_select cell_selector, text: Regexp.new("MyText"), count: 2
    assert_select cell_selector, text: Regexp.new("MyText"), count: 2
    assert_select cell_selector, text: Regexp.new("Display Name"), count: 2
  end
end
