require 'rails_helper'

RSpec.describe "tools/index", type: :view do
  before(:each) do
    assign(:tools, [
      Tool.create!(
        description: "Description",
        script: "MyText"
      ),
      Tool.create!(
        description: "Description",
        script: "MyText"
      )
    ])
  end

  it "renders a list of tools" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("Description".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("MyText".to_s), count: 2
  end
end
