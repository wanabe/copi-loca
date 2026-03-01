# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /operations/new", type: :request do
  it "renders a successful response" do
    get new_operation_url
    expect(response).to be_successful
  end
end
