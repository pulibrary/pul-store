require "resque/server"

PulStore::Application.routes.draw do
  resources :pages
  resources :texts
  resources :projects

  mount Resque::Server.new, :at => "/resque"

  scope module: 'pul_store' do
    namespace :lae do
      resources :boxes
      resources :folders
      resources :hard_drives
      get 'genres', to: 'genres#index'
      get 'genres/:id', to: 'genres#show'
      get 'categories/:category_id/subjects', to: 'subjects#index'
      get 'boxes/:id/folders', to: 'boxes#folders'
    end
  end

  root :to => "catalog#index"
  get '/lae', to: redirect('/lae/boxes')
  
  Blacklight.add_routes(self)
  # added with the splitting of BL-marc into sep. gem in BL 5.x series
  Blacklight::Marc.add_routes(self)
  #HydraHead.add_routes(self)

  # creates routes for any models defined in
  # config/initializers/hydra_editor.rb
  # routes at /records/:id/edit
  # or /reocords/new

  devise_for :users
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
