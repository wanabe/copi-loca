require 'rails_helper'

describe "GET /files/:id", type: :request do
  let(:file_path) { Dir.glob("/app/**/*").find { |f| File.file?(f) } }
  it "returns 200 and renders the show page for a real file" do
    get "/files", params: { path: file_path }
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(File.basename(file_path))
  end
end
