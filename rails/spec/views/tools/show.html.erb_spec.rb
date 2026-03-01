# frozen_string_literal: true

require "rails_helper"

RSpec.describe "tools/show", type: :view do
  before do
    assign(:tool, Tool.create!(
      name: "Tool Name",
      description: "Description",
      script: "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Description/)
    expect(rendered).to match(/MyText/)
  end
end
