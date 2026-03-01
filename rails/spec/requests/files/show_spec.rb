# frozen_string_literal: true

require "rails_helper"

describe "GET /files/:id", type: :request do
  it "returns 200 and renders the show page for a real file" do
    file_path = Dir.glob("/app/**/*").find { |f| File.file?(f) }.delete_prefix("/app/")
    get "/files/#{file_path}"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(File.basename(file_path))
  end

  it "returns 404 for a non-existent file" do
    get "/files/non_existent_file.txt"
    expect(response).to have_http_status(:not_found)
  end

  it "returns 400 for invalid path" do
    get "/files/../../etc/passwd"
    expect(response).to have_http_status(:bad_request)
    expect(response.body).to include("Invalid path")
  end
end
