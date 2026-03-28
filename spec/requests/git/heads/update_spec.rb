# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PATCH /git/refs/HEAD" do
  context "with a valid commit message" do
    it "amends the commit and redirects with notice" do
      commit_message = "Amend commit"
      allow(Git).to receive(:call!).with("commit", "--amend", "-m", commit_message)
      patch "/git/refs/HEAD", params: { commit_message: commit_message }
      expect(response).to redirect_to(new_git_head_path)
      expect(flash[:notice]).to eq("Amended commit successfully.")
    end
  end

  context "when amend raises an error" do
    it "redirects with alert" do
      commit_message = "Fail amend"
      allow(Git).to receive(:call!).with("commit", "--amend", "-m", commit_message).and_raise(StandardError.new("some error"))
      patch "/git/refs/HEAD", params: { commit_message: commit_message }
      expect(response).to redirect_to(edit_git_head_path)
      expect(flash[:alert]).to eq("Failed to amend commit: some error")
    end

    it "handles missing commit_message param" do
      allow(Git).to receive(:call!).with("commit", "--amend", "-m", nil).and_raise(StandardError.new("missing param"))
      patch "/git/refs/HEAD"
      expect(response).to redirect_to(edit_git_head_path)
      expect(flash[:alert]).to eq("Failed to amend commit: missing param")
    end
  end

  context "when commit_message param is missing" do
    it "raises and redirects with alert" do
      allow(Git).to receive(:call!).with("commit", "--amend", "-m", nil).and_raise(StandardError.new("missing param"))
      patch "/git/refs/HEAD"
      expect(response).to redirect_to(edit_git_head_path)
      expect(flash[:alert]).to eq("Failed to amend commit: missing param")
    end
  end
end
