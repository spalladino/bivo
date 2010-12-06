Bivo::Application.routes.draw do
  devise_for :users, :controllers => {:registrations => 'registrations' }
  match '/auth/facebook/callback' => 'facebook_authentications#create'

  #news
  post "news/:id/destroy", :to => "news#destroy"

  #gallery
  get "gallery/:entity_type/:entity_id/edit", :to => "galleries#edit", :as=>"edit_gallery"
  post "gallery/:entity_type/:entity_id/:id/move_up", :to => "galleries#move_up"
  post "gallery/:entity_type/:entity_id/:id/move_down", :to => "galleries#move_down"
  post "gallery/:entity_type/:entity_id/:id/remove_item", :to => "galleries#remove_item"
  post "gallery/:entity_type/:entity_id/add_photo", :to => "galleries#add_photo"
  post "gallery/:entity_type/:entity_id/add_video", :to => "galleries#add_video"

  #comments
  post "comments/:id/destroy", :to => "comments#destroy"
  get "comments/:id/edit", :to => "comments#edit"
  post "comments/:id/update", :to => "comments#update"
  post "comments/:id/approve", :to => "comments#approve"
  post "comments/create", :to => "comments#create"

  #incomes and expenses
  resources :expense_categories
  get "expense/list_categories", :to => "expense_categories#list_options"

  #incomes categories
  post "income_categories/create", :to => "income_categories#create"
  put "income_categories/update/:id", :to => "income_categories#update"
  delete "income_categories/:id", :to => "income_categories#destroy"

  #paths for admin manager
  get "admin/send_mails"
  get "admin/tools"
  get "admin/user_manager"
  get "admin/new_personal_user", :to => "admin#new_personal_user", :as => "admin_new_personal_user"
  post "admin/create_personal_user", :to => "admin#create_personal_user", :as => "admin_create_personal_user"
  get "admin/new_charity", :to => "admin#new_charity", :as => "admin_new_charity"
  post "admin/create_charity", :to => "admin#create_charity", :as => "admin_create_charity"
  get "admin/:id/edit_user", :to => "admin#edit_user", :as => "admin_edit_user"
  post "admin/update_user", :to => "admin#update_user", :as => "admin_update_user"
  post "admin/delete_user/:id", :to => "admin#delete_user", :as => "admin_delete_user"

  get 'admin/shop/categories', :to => 'shop_categories#edit', :as => 'admin_edit_shop_categories'
  post 'admin/shop/categories/create', :to => 'shop_categories#create'
  match 'admin/shop/categories/update', :to => 'shop_categories#update'
  match 'admin/shop/categories/delete', :to => 'shop_categories#destroy'

  #paths for handling eula
  get "eula", :to => "home#eula", :as => "eula"
  get "accept_eula",  :to => "home#accept_eula", :as => "accept_eula"
  post "confirm_eula", :to => "home#confirm_eula", :as => "confirm_eula"

  #paths for dashboard
  get "dashboard", :to => "home#dashboard", :as => "dashboard"
  get "stats", :to => "home#stats", :as => "stats"

  #paths for charities
  get "charity/check_url", :to => "charities#check_url"
  get "charity/c/:url", :controller => "charities", :action => "details", :constraints => { :url => Charity::UrlFormat }

  resources :charities, :path => 'charity' do
    member do
      get  :manage_comments
      post :activate
      post :deactivate
      post :follow
      post :unfollow
    end
    resources :news
  end

  get "shop/search/", :controller => "shops", :action => "search"
  get "shop/h/:short_url", :controller => "shops", :action => "home",:as => "shop_home", :constraints => { :short_url => Shop::UrlFormat }
  get "shop/c/:short_url", :controller => "shops", :action => "details",:as => "shop_details", :constraints => { :short_url => Shop::UrlFormat }

  resources :shops, :path => 'shop' do
    member do
      post :activate
      post :deactivate
    end
    collection do
      get :edit_categories
    end
  end

  get "cause/check_url", :controller => "causes", :action => "check_url", :as => 'check_cause_url'

  resources :causes, :path => 'cause/a' do
    member do
      post :activate
      post :deactivate
      post :mark_paid
      post :mark_unpaid
      post :vote
      post :follow
      post :unfollow
    end

    resources :news
  end



  get "cause/:url", :controller => "causes", :action => "details", :as => "cause_details", :constraints => { :url => Cause::UrlFormat }

  post "transaction/:id", :controller => "transactions", :action => "update",:as => "transaction_update"
  delete "transaction/:id",:controller => "transactions", :action => "destroy",:as => "transaction_destroy"
  get "transaction/:id/edit", :controller => "transactions", :action => "edit", :as => "transaction_edit"

  get "transaction", :controller => "transactions", :action => "index", :as => 'transaction_list'

  resources :transactions, :path => 'transaction', :except => :destroy

  get "change_language", :to => "home#change_language"

  # path for static pages
  get "how_it_works", :to => "home#how_it_works"
  get "jobs", :to => "home#jobs"
  get "social_initiatives", :to => "home#social_initiatives"
  get "fund_raisers", :to => "home#fund_raisers"
  get "about", :to => "home#about"

  root :to => "home#index"

  #post "cause/create", :to => 'causes#create', :as => 'create'
  #post "cause/:id/update", :to => 'causes#update'
  #post "cause/:id/delete", :to => 'causes#delete'

#  post "cause/:id/activate", :to => 'causes#activate'
#  post "cause/:id/deactivate", :to => 'causes#deactivate'
#  post "cause/:id/mark_paid", :to => 'causes#mark_paid'
#  post "cause/:id/vote", :to => 'causes#vote'
#  post "cause/:id/follow", :to => 'causes#follow'a
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

