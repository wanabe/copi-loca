require 'rails_helper'

RSpec.describe "operations/index", type: :view do
  before(:each) do
    assign(:operations, [
      Operation.create!(
        command: "Command",
        directory: "Directory"
      ),
      Operation.create!(
        command: "Command",
        directory: "Directory"
      )
    ])
  end

  it "renders a list of operations" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("Command".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Directory".to_s), count: 2
  end
end
