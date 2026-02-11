Rails.application.routes.draw do
  root to: 'sessions#index'

  get 'r', to: 'changes#revert'
  resources :changes, only: [] do
    collection do
      get :revert
      post :execute_revert
    end
  end

  resources :sessions, only: [:index, :show, :create, :destroy] do
    resources :messages, only: [:index, :create]
    resources :rpc_logs, only: [:index, :show]
  end
end
