require 'rails_helper'

RSpec.describe ApplicationController, type: :request do
  let(:controller_class) do
    Class.new(described_class) do
      before_action :authenticate
      def index
        render plain: 'ok'
      end
    end
  end

  before do
    stub_const('ENV', ENV.to_hash.merge('COPI_ADMIN_PASSWORD' => 'secret'))
    stub_const('AnonymousController', controller_class)
    Rails.application.routes_reloader.reload!
    Rails.application.routes.draw do
      get '/dummy_action', to: 'anonymous#index'
      get '/', as: :root, to: 'home#index'
      get '/auth_sessions/new', to: 'auth_sessions#new', as: :new_auth_session
      post '/auth_sessions', to: 'auth_sessions#create', as: :auth_sessions
    end
  end

  after do
    Rails.application.routes_reloader.reload!
  end

  describe '#authenticate', :with_auth do
    context 'without session admin' do
      it 'redirects to new auth session path' do
        get "/dummy_action"
        expect(response).to redirect_to("/auth_sessions/new")
      end
    end

    context 'with session admin' do
      before do
        post "/auth_sessions", params: { password: 'secret' }
      end

      it 'does not redirect and returns ok' do
        get "/dummy_action"
        expect(response.body).to eq('ok')
      end
    end
  end
end
