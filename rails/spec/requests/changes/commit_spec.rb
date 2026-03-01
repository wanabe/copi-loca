# frozen_string_literal: true

require "rails_helper"

describe "POST /changes/commit", type: :request do
  it "redirects to uncommitted_changes_path after commit" do
    allow(Repository).to receive(:commit)
    post "/changes/commit", params: { commit_message: "msg" }
    expect(response).to redirect_to(uncommitted_changes_path)
  end

  it "redirects to uncommitted_changes_path if commit_message is missing" do
    post "/changes/commit"
    expect(response).to redirect_to(uncommitted_changes_path)
  end
end
