require 'rails_helper'

RSpec.describe "custom_agents/show", type: :view do
  before(:each) do
    assign(:custom_agent, CustomAgent.create!(
      name: "Name",
      display_name: "Display Name",
      description: "MyText",
      prompt: "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Display Name/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/MyText/)
  end
end
