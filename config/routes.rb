DinerApp::Application.routes.draw do

  resources :posts

  get "payment_notification/create"

  get "sessions/new"

  resources :menu_items do
    put 'toggle_stock', :on => :member
    put 'change_order', :on => :member
    put 'add_option', :on => :member
    put 'remove_option', :on => :member
  end

  resources :categories do
    put 'change_order', :on => :member
  end

  resources :orders do
    put 'update_name', :on => :member
    put 'complete', :on => :member
    put 'add_item_to', :on => :member
    put 'remove_item_from', :on => :member
    put 'alter_option', :on => :member
  end

  resources :options do
    put 'toggle_stock', :on => :member
  end

  resources :sessions, :only => [:new, :create, :destroy]

  resources :settings do
    put 'activate', :on => :member
    put 'turn_off', :on => :member
  end

  match '/payment_notifications',	:to => 'payment_notification#create'
  match '/home',	:to => 'menu_items#home'
  match '/menu', 	:to => 'menu_items#index'
  match '/login',	:to => 'sessions#new'
  match '/logout',	:to => 'sessions#destroy'

  root :to => 'menu_items#home'
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
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
