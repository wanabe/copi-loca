# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Git::Dashboard::Show do
  subject(:rendered) { render described_class.new }

  it "renders the Git header and Grep link" do
    expect(rendered).to include("Git")
    expect(rendered).to include("Grep")
    expect(rendered).to include("/git/grep")
    expect(rendered).to include("text-2xl font-bold mb-4")
    expect(rendered).to include("text-blue-600 hover:underline")
  end
end
