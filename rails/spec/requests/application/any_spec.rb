# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /any", type: :request do
  let(:controller_class) do
    Class.new(ApplicationController) do
      def any
        render plain: "ok"
      end
    end
  end

  before do
    stub_const("ENV", ENV.to_hash.merge("COPI_ADMIN_PASSWORD" => "secret"))
    stub_const("AnonymousController", controller_class)
    Rails.application.routes_reloader.reload!
    Rails.application.routes.draw do
      get "/any", to: "anonymous#any"
      get "/", as: :root, to: "home#index"
      get "/auth_sessions/new", to: "auth_sessions#new", as: :new_auth_session
      post "/auth_sessions", to: "auth_sessions#create", as: :auth_sessions
    end
  end

  after do
    Rails.application.routes_reloader.reload!
  end

  describe "#authenticate", :with_auth do
    context "without session" do
      it "redirects to new auth session path" do
        get "/any"
        expect(response).to redirect_to("/auth_sessions/new")
      end
    end

    context "when logged in" do
      before do
        post "/auth_sessions", params: { password: "secret" }
      end

      it "does not redirect and returns ok" do
        get "/any"
        expect(response.body).to eq("ok")
      end
    end
  end
end
