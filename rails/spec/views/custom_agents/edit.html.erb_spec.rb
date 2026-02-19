require 'rails_helper'

RSpec.describe "custom_agents/edit", type: :view do
  let(:custom_agent) {
    CustomAgent.create!(
      name: "MyString",
      display_name: "MyString",
      description: "MyText",
      prompt: "MyText"
    )
  }

  before(:each) do
    assign(:custom_agent, custom_agent)
  end

  it "renders the edit custom_agent form" do
    render

    assert_select "form[action=?][method=?]", custom_agent_path(custom_agent), "post" do
      assert_select "input[name=?]", "custom_agent[name]"

      assert_select "input[name=?]", "custom_agent[display_name]"

      assert_select "textarea[name=?]", "custom_agent[description]"

      assert_select "textarea[name=?]", "custom_agent[prompt]"
    end
  end
end
