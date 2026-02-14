Rails.application.routes.draw do
  root to: "home#index"
  resources :files, only: [:index]
  get 'files/*path', to: 'files#show', as: :file, format: "html"

  get "r", to: "changes#revert"
  resources :changes, only: [] do
    collection do
      get :index
      get :uncommitted, as: :uncommitted_changes
      get :revert
      post :execute_revert
    end
    member do
      get :show, constraints: { id: /[0-9a-f]{40}/ }
    end
  end

  resources :models, only: [ :index ]

  resources :sessions, only: [ :index, :show, :create, :destroy ] do
    resources :messages, only: [ :index, :create ]
    resources :rpc_logs, only: [ :index, :show ]
  end

  resources :auth_sessions, only: [ :new, :create, :destroy ]

  resources :app_ops, only: [:index] do
    collection do
      get :confirm, to: 'app_ops#confirm', as: :confirm
      post :bundle_install, to: 'app_ops#bundle_install', as: :bundle_install
    end
  end
end
