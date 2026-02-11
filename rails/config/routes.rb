Rails.application.routes.draw do
  root to: 'sessions#index'

  resources :sessions, only: [:index, :show, :create, :destroy] do
    resources :messages, only: [:index, :create]
    resources :rpc_logs, only: [:index, :show]
  end
end
