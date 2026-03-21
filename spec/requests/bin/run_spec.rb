# frozen_string_literal: true

require "rails_helper"

RSpec.describe "POST /bin/:id/run" do
  let(:bin) { Bin.new(id: "some_tool") }

  before do
    allow(Bin).to receive(:find).with("some_tool").and_return(bin)
    allow(bin).to receive(:run).and_return([128, "output text"])
  end

  it "renders the run component with status and output" do
    post run_bin_path(bin.id), params: {}, headers: { "Accept" => "text/html" }
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("output text")
    expect(response.body).to include("128")
  end
end
