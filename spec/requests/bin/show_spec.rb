# frozen_string_literal: true

require "rails_helper"

RSpec.describe "BinController#show" do
  let(:bin) { Bin.new(id: "test.rb") }

  before do
    allow(bin).to receive(:path).and_return(Rails.root.join("bin/test.rb"))
    allow(Bin).to receive(:find).and_return(bin)
  end

  it "renders the show template with the bin" do
    get "/bin/#{bin.id}"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("test.rb")
  end
end
