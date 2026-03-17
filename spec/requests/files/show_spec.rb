# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /files/*path" do
  let(:base_path) { "/app" }

  context "when path is a directory" do
    it "renders the directory view with entries" do
      allow(File).to receive_messages(absolute_path: base_path, exist?: true, ftype: "directory")
      allow(Dir).to receive(:entries).and_return([".", "..", "file1.txt", "subdir"])
      get files_path(path: "")
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("file1.txt")
      expect(response.body).to include("subdir")
    end
  end

  context "when path is a file" do
    it "renders the file view with content" do
      allow(File).to receive_messages(absolute_path: "#{base_path}/file1.txt", exist?: true, ftype: "file", read: "Sample content")
      get files_path(path: "file1.txt", raw: "false")
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Sample content")
    end

    it "sends the file when raw is not 'false'" do
      # on the test, `/copi-loca` === `app`
      path = Pathname.new(__FILE__).relative_path_from(Rails.root).to_s
      get files_path(path: path, raw: "true")
      expect(response).to have_http_status(:ok)
      expect(response.header["Content-Disposition"]).to include("inline")
      expect(response.body).to eq(File.read(__FILE__))
    end
  end

  context "when file does not exist" do
    it "returns not found error" do
      allow(File).to receive_messages(absolute_path: "#{base_path}/missing.txt", exist?: false)
      get files_path(path: "missing.txt")
      expect(response).to have_http_status(:not_found)
      expect(response.body).to include("File not found")
    end
  end

  context "when path is invalid" do
    it "returns bad request error" do
      allow(File).to receive_messages(absolute_path: "/etc/passwd", exist?: true)
      get files_path(path: "../../etc/passwd")
      expect(response).to have_http_status(:bad_request)
      expect(response.body).to include("Invalid path")
    end
  end

  context "when file type is unsupported" do
    it "returns unsupported media type error" do
      allow(File).to receive_messages(absolute_path: "#{base_path}/socket", exist?: true, ftype: "socket")
      get files_path(path: "socket")
      expect(response).to have_http_status(:unsupported_media_type)
      expect(response.body).to include("Unsupported file type")
    end
  end
end
