require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller(ApplicationController) do
    before_action :authenticate
    def index
      render plain: 'ok'
    end
  end

  before do
    stub_const('ENV', ENV.to_hash.merge('COPI_ADMIN_PASSWORD' => 'secret'))
  end

  describe '#authenticate', :with_auth do
    context 'without session admin' do
      before do
        session[:admin] = nil
      end

      it 'returns ok' do
        get :index
        expect(response).to redirect_to(new_auth_session_path)
      end
    end

    context 'with session admin' do
      before do
        session[:admin] = true
      end

      it 'returns ok' do
        get :index
        expect(response.body).to eq('ok')
      end
    end
  end
end
