Rails.application.routes.draw do
  root to: "home#index"
  resources :files, only: [:index]
  get 'files/*path', to: 'files#show', as: :file, format: "html"

  get "r", to: "changes#revert"
  resources :changes, only: [] do
    collection do
      get :uncommitted, as: :uncommitted_changes
      get :revert
      post :execute_revert
    end
  end

  resources :models, only: [ :index ]

  resources :sessions, only: [ :index, :show, :create, :destroy ] do
    resources :messages, only: [ :index, :create ]
    resources :rpc_logs, only: [ :index, :show ]
  end

  resources :auth_sessions, only: [ :new, :create, :destroy ]
end
