Rails.application.routes.draw do
  resources :tools
  resources :custom_agents
  root to: "home#index"

  resources :files, only: [ :index ]
  get "files/*path", to: "files#show", as: :file, format: "html"

  get "r", to: "changes#revert"
  resources :changes, only: [] do
    collection do
      get :index
      get :uncommitted
      get :revert
      post :execute_revert
      post :stage
    end
    member do
      get :show, constraints: { id: /[0-9a-f]{40}/ }
    end
  end

  resources :models, only: [ :index ]

  resources :sessions, only: [ :new, :update, :edit, :index, :show, :create, :destroy ] do
    resources :messages, only: [ :index, :create ] do
      collection do
        get :history
      end
    end
    resources :rpc_messages, only: [ :index, :show ]
    resources :events, only: [ :index, :show ]
  end

  resources :auth_sessions, only: [ :new, :create, :destroy ]

  resources :operations do
    member do
      post :run
    end
  end
end
