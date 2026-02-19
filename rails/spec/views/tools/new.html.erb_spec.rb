require 'rails_helper'

RSpec.describe "tools/new", type: :view do
  before(:each) do
    assign(:tool, Tool.new(
      description: "MyString",
      script: "MyText"
    ))
  end

  it "renders new tool form" do
    render

    assert_select "form[action=?][method=?]", tools_path, "post" do
      assert_select "input[name=?]", "tool[description]"

      assert_select "textarea[name=?]", "tool[script]"
    end
  end
end
