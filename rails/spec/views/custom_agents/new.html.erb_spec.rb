require 'rails_helper'

RSpec.describe "custom_agents/new", type: :view do
  before(:each) do
    assign(:custom_agent, CustomAgent.new(
      name: "MyString",
      display_name: "MyString",
      description: "MyText",
      prompt: "MyText"
    ))
  end

  it "renders new custom_agent form" do
    render

    assert_select "form[action=?][method=?]", custom_agents_path, "post" do
      assert_select "input[name=?]", "custom_agent[name]"

      assert_select "input[name=?]", "custom_agent[display_name]"

      assert_select "textarea[name=?]", "custom_agent[description]"

      assert_select "textarea[name=?]", "custom_agent[prompt]"
    end
  end
end
