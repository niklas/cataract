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

  resource :scraping, only: [:new, :create]

  devise_for :users, :controllers => { :registrations => "user::registrations" }

  root :to => 'greetings#dashboard'
  get "dashboard" => 'greetings#dashboard', :as => 'user_root' # after login

  if Rails.env.test?
    scope 'test' do
      get 'sign_in' => 'test_acceleration#sign_in', as: 'fast_sign_in'
    end
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
