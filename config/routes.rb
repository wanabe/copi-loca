# frozen_string_literal: true

Rails.application.routes.draw do
  resources :prompts do
    member do
      post :run
    end
  end

  resources :ps, only: [:index]

  resources :bin, only: %i[index show] do
    member do
      post :run
    end
  end

  get "files", to: "files#show", format: false
  get "files/*path", to: "files#show", as: :file, format: false

  resources :memos, only: [:index] do
    collection do
      post :sync_local_memos
    end
  end

  namespace :git do
    root to: "dashboard#show"

    resources :refs, only: [:index]
    scope "refs/*ref/-", as: :ref do
      get "grep", to: "grep#show"
      get "entries/*path", to: "entries#show", as: :entry, format: false
      get "entries", to: "entries#show", as: :entries_root
    end
    get "refs/*ref", to: "refs#show", as: :ref

    # resource :head, only: [] # commit/amend
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
end
