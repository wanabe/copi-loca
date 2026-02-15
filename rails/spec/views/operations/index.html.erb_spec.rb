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
    cell_selector = 'div > strong'
    assert_select cell_selector, text: /Command:/, count: 2
    assert_select cell_selector, text: /Directory:/, count: 2
  end
end
