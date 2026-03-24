# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /bin" do
  let!(:bins) { %w[brakeman bundler-audit check].map { |id| Bin.new(id: id) } }

  before do
    allow(Bin).to receive(:all).and_return(bins)
  end

  it "returns a successful response" do
    get "/bin"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(bins.first.id.to_s)
  end

  it "paginates bins" do
    get "/bin", params: { per_page: 2 }
    expect(response.body).to include(bins[0].id)
    expect(response.body).to include(bins[1].id)
    expect(response.body).not_to include(bins[2].id)
  end
end
