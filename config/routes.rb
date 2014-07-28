Rails.application.routes.draw do
  get '/' => redirect("/signin")
  get 'signin' => 'sessions#new', :as => 'signin'
  delete 'signout' => 'sessions#destroy', :as => 'signout'
  post '/contests/:id/participate' => 'contests#participate', :as => 'participate_contest'
  delete '/contests/:id/unparticipate' => 'contests#unparticipate', :as => 'unparticipate_contest'
  get '/contests/:id/leaderboard' => 'contests#leaderboard', :as => 'leaderboard'
  get '/contests/invited' => 'contests#invited', :as => 'invited_contests'
  get '/contests/ongoing' => 'contests#ongoing', :as => 'ongoing_contests'
  get '/users/ongoing_contests' => 'users#ongoing_contests'
  patch '/users/:id/admin' => 'users#set_admin', :as => 'set_admin'
  get '/users/:id/submissions' => 'submissions#user', :as => 'user_submissions'
  resources :problems, :only => [:index, :new, :create, :show, :edit, :update]
  resources :users, :only => [:index, :new, :create, :show, :edit, :update]
  resources :sessions, :only => :create
  resources :submissions, :only => [:index, :create, :show]
  resources :contests, :only => [:index, :new, :create, :show, :edit, :update]
  resources :announcements, :only => :create

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
