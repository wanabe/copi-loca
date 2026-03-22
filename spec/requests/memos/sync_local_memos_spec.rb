# frozen_string_literal: true

require "rails_helper"

RSpec.describe "POST /memos/sync_local_memos" do
  let(:memos) { { "memos" => [{ "text" => "Memo 1", "ts" => 1234 }, { "text" => "Memo 2", "ts" => 5678 }] } }

  it "saves memos to docs/memos.json and returns success" do
    path_double = instance_double(Pathname, write: nil)
    allow(Rails.root).to receive("join").with("docs/memos.json").and_return(path_double)
    allow(path_double).to receive(:write) do |content|
      expect(JSON.parse(content)).to eq(memos)
    end
    post sync_local_memos_memos_path, params: memos.to_json, headers: { "CONTENT_TYPE" => "application/json" }
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("success")
    expect(path_double).to have_received(:write)
  end

  it "returns error for invalid JSON" do
    post sync_local_memos_memos_path, params: "invalid", headers: { "CONTENT_TYPE" => "application/json" }
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("error")
  end
end
