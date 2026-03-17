# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Home::Index do
  it "renders the home title and links" do
    html = described_class.new.call
    expect(html).to include("<h1>Home</h1>")
    expect(html).to include('href="/bin"')
    expect(html).to include(">Bin<")
    expect(html).to include('href="/files"')
    expect(html).to include(">Files<")
    expect(html).to include('href="/ps"')
    expect(html).to include(">Processes<")
    expect(html).to include('href="/prompts"')
    expect(html).to include(">Prompts<")
  end
end
