# frozen_string_literal: true

require "rails_helper"

RSpec.describe "operations/show" do
  before do
    assign(:operation, Operation.create!(
      command: "Command",
      directory: "Directory"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Command/)
    expect(rendered).to match(/Directory/)
  end
end
