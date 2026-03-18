# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Home::Index do
  subject(:rendered) { render described_class.new }

  it "renders the home title and links" do
    expect(rendered).to include(">Home<")
    expect(rendered).to include('href="/bin"')
    expect(rendered).to include(">Bin<")
    expect(rendered).to include('href="/files"')
    expect(rendered).to include(">Files<")
    expect(rendered).to include('href="/memos"')
    expect(rendered).to include(">Memos<")
    expect(rendered).to include('href="/ps"')
    expect(rendered).to include(">Ps<")
    expect(rendered).to include('href="/prompts"')
    expect(rendered).to include(">Prompts<")
  end
end
