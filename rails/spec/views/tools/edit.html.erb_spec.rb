# frozen_string_literal: true

require "rails_helper"

RSpec.describe "tools/edit", type: :view do
  let(:tool) do
    Tool.create!(
      name: "MyString",
      description: "MyString",
      script: "MyText"
    )
  end

  before do
    assign(:tool, tool)
  end

  it "renders the edit tool form" do
    render

    assert_select "form[action=?][method=?]", tool_path(tool), "post" do
      assert_select "input[name=?]", "tool[description]"

      assert_select "textarea[name=?]", "tool[script]"
    end
  end
end
