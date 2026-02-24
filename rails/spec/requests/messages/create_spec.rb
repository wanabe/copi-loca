require 'rails_helper'

RSpec.describe "POST /sessions/:session_id/messages", type: :request do
  let(:session) { Session.create!(id: SecureRandom.uuid, model: "gpt-4.1") }
  before { allow(SendPromptJob).to receive(:perform_later) }

  it "creates a message async and redirects" do
    post "/sessions/#{session.id}/messages", params: { message: { content: "new message" } }
    expect(response).to have_http_status(:found)
    follow_redirect!
    expect(SendPromptJob).to have_received(:perform_later)
  end

  it "handles file upload (mocked)" do
    uploaded = double("uploaded", original_filename: "mock.txt", read: "mockdata")
    allow(uploaded).to receive(:respond_to?).with(:original_filename).and_return(true)
    allow(File).to receive(:open)
    post "/sessions/#{session.id}/messages", params: { file: uploaded, message: { content: "file msg" } }
    expect(response).to redirect_to(action: :index)
    expect(SendPromptJob).to have_received(:perform_later)
  end

  it "handles camera_file upload (mocked)" do
    uploaded = double("uploaded", original_filename: "mock.txt", read: "mockdata")
    allow(uploaded).to receive(:respond_to?).with(:original_filename).and_return(true)
    allow(File).to receive(:open)
    post "/sessions/#{session.id}/messages", params: { camera_file: uploaded, message: { content: "cam msg" } }
    expect(response).to redirect_to(action: :index)
    expect(SendPromptJob).to have_received(:perform_later)
  end

  it "handles blank content (index)" do
    post "/sessions/#{session.id}/messages", params: { message: { content: "   " } }
    expect(response).to redirect_to(action: :index)
  end

  it "handles blank content (session_show)" do
    post "/sessions/#{session.id}/messages", params: { message: { content: "   " }, from: "session_show" }
    expect(response).to redirect_to(session_path(session))
  end

  it "handles custom_agent_id" do
    agent = CustomAgent.create!(name: "test")
    SessionCustomAgent.create!(session: session, custom_agent: agent)
    post "/sessions/#{session.id}/messages", params: { message: { content: "msg" }, custom_agent_id: agent.id }
    expect(response).to redirect_to(action: :index)
    expect(SendPromptJob).to have_received(:perform_later)
  end

  it "handles display_state params" do
    post "/sessions/#{session.id}/messages", params: { message: { content: "msg" }, show_messages: "true", show_rpc_messages: "false", show_events: "true" }
    expect(response).to redirect_to(action: :index)
    expect(SendPromptJob).to have_received(:perform_later)
  end

  it "handles turbo_stream blank content" do
    post "/sessions/#{session.id}/messages", params: { message: { content: "   " } }, headers: { "Accept" => "text/vnd.turbo-stream.html" }
    expect(response).to have_http_status(:ok)
  end

  it "handles turbo_stream normal content" do
    post "/sessions/#{session.id}/messages", params: { message: { content: "msg" } }, headers: { "Accept" => "text/vnd.turbo-stream.html" }
    expect(response).to have_http_status(:ok)
    expect(SendPromptJob).to have_received(:perform_later)
  end

  describe "file and camera_file upload with Rack::Test::UploadedFile" do
    it "uploads file param" do
      file = Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/test.txt"), "text/plain")
      post "/sessions/#{session.id}/messages", params: { file: file, message: { content: "file upload" } }
      expect(response).to redirect_to(action: :index)
      expect(SendPromptJob).to have_received(:perform_later)
    end

    it "uploads camera_file param" do
      file = Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/test.txt"), "text/plain")
      post "/sessions/#{session.id}/messages", params: { camera_file: file, message: { content: "camera upload" } }
      expect(response).to redirect_to(action: :index)
      expect(SendPromptJob).to have_received(:perform_later)
    end
  end

  describe "custom_agent and redirect target" do
    it "handles custom_agent_id param" do
      agent = CustomAgent.create!(name: "test")
      SessionCustomAgent.create!(session: session, custom_agent: agent)
      post "/sessions/#{session.id}/messages", params: { message: { content: "msg" }, custom_agent_id: agent.id }
      expect(response).to redirect_to(action: :index)
      expect(SendPromptJob).to have_received(:perform_later)
    end

    it "redirects to session_show when from param is set" do
      post "/sessions/#{session.id}/messages", params: { message: { content: "msg" }, from: "session_show" }
      expect(response).to redirect_to(session_path(session))
      expect(SendPromptJob).to have_received(:perform_later)
    end
  end
end
