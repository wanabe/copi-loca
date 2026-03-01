# frozen_string_literal: true

require "rails_helper"

RSpec.describe "tools/index", type: :view do
  before do
    assign(:tools, [
      Tool.create!(
        name: "Name",
        description: "Description",
        script: "MyText"
      ),
      Tool.create!(
        name: "Name",
        description: "Description",
        script: "MyText"
      )
    ])
  end

  it "renders a list of tools" do
    render
    cell_selector = "div#tools>div"
    assert_select cell_selector, text: Regexp.new("Description"), count: 2
    assert_select cell_selector, text: Regexp.new("MyText"), count: 2
  end
end
