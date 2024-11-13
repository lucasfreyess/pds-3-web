Rails.application.routes.draw do
  resources :controladorrs
  
  devise_for :users, controllers: { 
    sessions: 'users/sessions',
    omniauth_callbacks: 'users/omniauth_callbacks' 
  }
  
  root "home#index"
  
  
  #get "controllers" => "controllers#index"
  #get "controllers/available" => "controllers#available", as: :available_controllers
  #get "controllers/new" => "controllers#new", as: :new_controller
  #get "controllers/:id" => "controllers#show", as: :show_controller
  #patch "controllers/:id/assign_to_user" => "controllers#assign_to_user", as: :assign_to_user_controller
  #patch "controllers/:id/unlink_from_user" => "controllers#unlink_from_user", as: :unlink_from_user_controller
  #post "controllers" => "controllers#create"

  # get "models" => "models#index"
  # get "models/:id" => "models#show", as: :model
  post "models/:model_id/update_user_model" => "models#update_user_model", as: :update_user_model
  
  # get "lockers/:id/edit" => "lockers#edit", as: :edit_locker
  # patch "lockers/:id" => "lockers#update", as: :update_locker
  
  resources :controllers do
    collection do
      get 'available', to: 'controllers#available', as: :available
    end

    member do
      patch 'assign_to_user', to: 'controllers#assign_to_user', as: :assign_to_user
      patch 'unlink_from_user', to: 'controllers#unlink_from_user', as: :unlink_from_user
    end
  end

  resources :models, only: [:index, :show] do
    #member do
    #  post 'update_user_model', to: 'models#update_user_model', as: :update_user_model
    #end
  end

  resources :lockers, only: [:edit, :update]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  post 'send_message', to: 'mqtt#send_message'
end