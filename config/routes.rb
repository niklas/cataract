Cataract::Application.routes.draw do
  get "greetings/dashboard"

  resources :settings, only: [:show, :update]
  resources :torrents do
    member do
      get 'prepend'
    end
  end

  resources :torrents

  # Ember-data cannot handle nested resources (yet?)
  resources :transfers, only: [:create, :index, :destroy], controller: :transfer
  resources :payloads, only: [:show, :destroy], controller: :payload
  resources :moves, only: [:create, :index]
  resources :detected_directories, only: :index
  resources :disks
  resources :directories
  resources :remote_torrents, only: [:index]
  resources :feeds, only: [:index]

  resource :scraping, only: [:new, :create] do
    member do
      get :open
    end
  end

  devise_for :users, :controllers => { :registrations => "user/registrations" }

  root :to => 'greetings#dashboard'
  get "dashboard" => 'greetings#dashboard', :as => 'user_root' # after login

  if Rails.env.test?
    scope 'test' do
      get 'sign_in' => 'test_acceleration#sign_in', as: 'fast_sign_in'
    end
  end

end
