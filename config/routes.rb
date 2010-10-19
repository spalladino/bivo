Bivo::Application.routes.draw do
  devise_for :users

  resources :charities

  get "cause/c/:url", :controller => "causes", :action => "details", :constraints => { :url => Cause::UrlFormat }
  get "cause/check_url", :controller => "causes", :action => "check_url", :as => 'check_cause_url'

  resources :causes, :path => 'cause' do
    member do
      post :activate
      post :deactivate
      post :mark_paid
      post :vote
      post :follow
      post :unfollow
    end
  end

  root :to => "home#index"

  #post "cause/create", :to => 'causes#create', :as => 'create'
  #post "cause/:id/update", :to => 'causes#update'
  #post "cause/:id/delete", :to => 'causes#delete'

#  post "cause/:id/activate", :to => 'causes#activate'
#  post "cause/:id/deactivate", :to => 'causes#deactivate'
#  post "cause/:id/mark_paid", :to => 'causes#mark_paid'
#  post "cause/:id/vote", :to => 'causes#vote'
#  post "cause/:id/follow", :to => 'causes#follow'
#  post "cause/:id/unfollow", :to => 'causes#unfollow'


  #get "cause", :to => 'causes#index'
  #get "cause/new", :to => 'causes#new'
  #get "cause/checkUrl", :to => 'causes#checkUrl'

  #get "cause/:id/edit", :to => 'causes#edit'


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

