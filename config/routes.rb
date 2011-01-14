Bivo::Application.routes.draw do

  constraints(ShopSubdomain) do
    get ":short_url", :controller => "shops", :action => "home", :constraints => { :short_url => Shop::UrlFormat, :subdomain => /shop/ }
    get ":short_url/details", :controller => "shops", :action => "details", :constraints => { :short_url => Shop::UrlFormat, :subdomain => /shop/ }
  end

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
  get "admin/user_manager", :as => "admin_user_manager"
  get "admin/new_personal_user", :to => "admin#new_personal_user", :as => "admin_new_personal_user"
  post "admin/create_personal_user", :to => "admin#create_personal_user", :as => "admin_create_personal_user"
  get "admin/new_charity", :to => "admin#new_charity", :as => "admin_new_charity"
  post "admin/create_charity", :to => "admin#create_charity", :as => "admin_create_charity"

  post "admin/delete_user/:id", :to => "admin#delete_user", :as => "admin_delete_user"

  get 'admin/shop/categories', :to => 'shop_categories#edit', :as => 'admin_edit_shop_categories'
  post 'admin/shop/categories/create', :to => 'shop_categories#create'
  match 'admin/shop/categories/update', :to => 'shop_categories#update'
  match 'admin/shop/categories/delete', :to => 'shop_categories#destroy'

  get 'admin/language', :to => "admin#choose_language", :as => 'translation'
  get 'admin/translate', :to => "admin#translate"

  post 'admin/save_translation', :to => "admin#save_translation"

  #paths for handling eula
  get "eula", :to => "home#eula", :as => "eula"
  get "accept_eula",  :to => "home#accept_eula", :as => "accept_eula"
  post "confirm_eula", :to => "home#confirm_eula", :as => "confirm_eula"

  #paths for dashboard
  get "dashboard", :to => "home#dashboard", :as => "dashboard"
  get "stats", :to => "home#stats", :as => "stats"

  #paths for charities
  get "charity/a/check_url", :to => "charities#check_url"

  resources :charities, :path => 'charity/a' do
    member do
      get  :manage_comments
      post :activate
      post :deactivate
      post :follow
      post :unfollow
    end
    resources :news
  end

  get "charity/:url", :controller => "charities", :action => "details", :constraints => { :url => Charity::UrlFormat }

  get "shop/a/search/", :controller => "shops", :as => "shop_search", :action => "search"

  resources :shops, :path => 'shop/a' do
    member do
      post :activate
      post :deactivate
    end
    collection do
      get :edit_categories
    end
  end

  get "cause/a/check_url", :controller => "causes", :action => "check_url", :as => 'check_cause_url'

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

  post "change_language", :to => "home#change_language"
  post "change_currency", :to => "home#change_currency"

  # path for static pages
  get "about(/:id)", :to => "home#about"
  get "about/:locale/:id", :to => "home#about"

  root :to => "home#index"

end

