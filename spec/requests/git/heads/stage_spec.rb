# frozen_string_literal: true

require "rails_helper"

RSpec.describe "POST /git/refs/HEAD/-/stage" do
  it "stages the file and redirects with notice" do
    file_path = "test.txt"
    allow(Git).to receive(:call!).with("add", "--", file_path)
    post "/git/refs/HEAD/-/stage", params: { file_path: file_path }
    expect(response).to redirect_to(new_git_head_path)
    expect(flash[:notice]).to eq("#{file_path} has been staged.")
  end

  context "when amend param is true" do
    it "redirects to edit_git_head_path" do
      file_path = "test.txt"
      allow(Git).to receive(:call!).with("add", "--", file_path)
      post "/git/refs/HEAD/-/stage", params: { file_path: file_path, amend: "true" }
      expect(response).to redirect_to(edit_git_head_path)
      expect(flash[:notice]).to eq("#{file_path} has been staged.")
    end
  end
end
