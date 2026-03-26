# frozen_string_literal: true

require "rails_helper"

RSpec.describe "POST /git/refs/HEAD" do
  context "with a valid commit message" do
    it "commits and redirects with notice" do
      commit_message = "Test commit"
      allow(Git).to receive(:call!).with("commit", "-m", commit_message)
      post "/git/refs/HEAD", params: { commit_message: commit_message }
      expect(response).to redirect_to(new_git_head_path)
      expect(flash[:notice]).to eq("Committed successfully.")
    end
  end

  context "when commit raises an error" do
    it "redirects with alert" do
      commit_message = "Fail commit"
      allow(Git).to receive(:call!).with("commit", "-m", commit_message).and_raise(StandardError.new("some error"))
      post "/git/refs/HEAD", params: { commit_message: commit_message }
      expect(response).to redirect_to(new_git_head_path)
      expect(flash[:alert]).to eq("Failed to commit: some error")
    end
  end
end
