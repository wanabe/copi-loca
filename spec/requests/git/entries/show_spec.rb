# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /git/entries/:ref/-/:path or /git/entries/:ref" do
  let(:ref) { "main" }
  let(:path) { "README.md" }

  context "when path is not provided" do
    it "renders the tree view for the root directory" do
      allow(Git).to receive(:call).and_return(<<~OUTPUT)
        100644 blob abcdef1234567890abcdef1234567890abcdef12\tREADME.md
        40000 tree 1234567890abcdef1234567890abcdef12345678\tlib
      OUTPUT
      get git_ref_entries_root_path(ref: ref)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Tree #{ref}:.")
      expect(Git).to have_received(:call).with("ls-tree", ref, "--", "./")
    end
  end

  context "when path is provided and entry is a tree" do
    let(:path) { "lib" }

    it "renders the tree view for the directory" do
      allow(Git).to receive(:call).and_return(<<~SELF, <<~ENTRIES)
        40000 tree 1234567890abcdef1234567890abcdef12345678\tlib
      SELF
        100644 blob abcdef1234567890abcdef1234567890abcdef12\tlib/file1.rb
        100644 blob abcdef1234567890abcdef1234567890abcdef34\tlib/file2.rb
      ENTRIES
      get git_ref_entry_path(ref: ref, path: path)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Tree #{ref}:#{path}")
      expect(Git).to have_received(:call).with("ls-tree", ref, "--", path.to_s)
      expect(Git).to have_received(:call).with("ls-tree", ref, "--", "#{path}/")
    end
  end

  context "when path is provided and entry is a blob" do
    let(:path) { "README.md" }

    it "renders the blob view for the file" do
      allow(Git).to receive(:call).and_return(<<~SELF, "Hello, world!")
        100644 blob abcdef1234567890abcdef1234567890abcdef12\tREADME.md
      SELF
      get git_ref_entry_path(ref: ref, path: path, raw: false)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Blob #{ref}:#{path}")
      expect(response.body).to include("Hello, world!")
      expect(Git).to have_received(:call).with("ls-tree", ref, "--", path.to_s)
      expect(Git).to have_received(:call).with("show", "#{ref}:#{path}")
    end

    it "renders the raw content when raw is true" do
      allow(Git).to receive(:call).and_return(<<~SELF, "Hello, world!")
        100644 blob abcdef1234567890abcdef1234567890abcdef12\tREADME.md
      SELF
      get git_ref_entry_path(ref: ref, path: path, raw: true)
      expect(response).to have_http_status(:ok)
      expect(response.header["Content-Disposition"]).to include("inline")
      expect(response.body).to eq("Hello, world!")
      expect(Git).to have_received(:call).with("ls-tree", ref, "--", path.to_s)
      expect(Git).to have_received(:call).with("show", "#{ref}:#{path}")
    end
  end

  context "when path does not exist" do
    it "returns not found" do
      allow(Git).to receive(:call).and_return("")
      get git_ref_entry_path(ref: ref, path: path)
      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body["error"]).to eq("Not found")
      expect(Git).to have_received(:call).with("ls-tree", ref, "--", path.to_s)
    end
  end

  context "when multiple entries are found" do
    it "returns unprocessable content" do
      allow(Git).to receive(:call).and_return(<<~OUTPUT)
        100644 blob abcdef1234567890abcdef1234567890abcdef12\tREADME.md
        100644 blob abcdef1234567890abcdef1234567890abcdef34\tREADME.md
      OUTPUT
      get git_ref_entry_path(ref: ref, path: path)
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["error"]).to eq("Multiple entries found")
      expect(Git).to have_received(:call).with("ls-tree", ref, "--", path.to_s)
    end
  end

  context "when entry type is unsupported" do
    it "returns unsupported media type" do
      allow(Git).to receive(:call).and_return(<<~OUTPUT)
        100644 commit abcdef1234567890abcdef1234567890abcdef34\tREADME.md
      OUTPUT
      get git_ref_entry_path(ref: ref, path: path)
      expect(response).to have_http_status(:unsupported_media_type)
      expect(response.parsed_body["error"]).to eq("Unsupported entry type")
      expect(Git).to have_received(:call).with("ls-tree", ref, "--", path.to_s)
    end
  end
end
