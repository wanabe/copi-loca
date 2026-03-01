# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /custom_agents/new", type: :request do
  it "renders a successful response" do
    get new_custom_agent_url
    expect(response).to be_successful
  end
end
