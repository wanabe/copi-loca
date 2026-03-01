# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /tools/new", type: :request do
  it "renders a successful response" do
    get new_tool_url
    expect(response).to be_successful
  end
end
