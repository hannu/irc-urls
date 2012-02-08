IrcUrls::Application.routes.draw do
  def type(controller, path, viewtype = true)
    interval_constraint = /((\d+)\s?(\w+)|alltime)/
    viewtype_constraint = /(list|grid)/

    scope path do
      match "recent/:viewtype", :to => "#{controller}#recent", :constraints => {:viewtype => viewtype_constraint}, :via => :get if viewtype
      match "top/:interval(/:viewtype)", :to => "#{controller}#index", :constraints => {:viewtype => viewtype_constraint}, :via => :get if viewtype
      match ":viewtype", :to => "#{controller}#index", :constraints => {:viewtype => viewtype_constraint}
      match "top/:interval", :to => "#{controller}#index", :constraints => {:interval => interval_constraint}, :via => :get
    end

    if block_given?
      yield
    else
      match "/", :to => "#{controller}#index"
    end

    resources controller, :path => path, :only => :index do
      collection do
        get :recent
      end
    end

    scope path do
      match "top", :to => "#{controller}#index", :as => "top_#{controller}", :via => :get
    end

  end

  def occurrences(&blk)
    type(:occurrences, "urls", false, &blk)
    type(:video_occurrences, "videos", &blk)
    type(:image_occurrences, "images", &blk)
    type(:media_occurrences, "media", &blk)
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
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
  resource :submissions

  # We don't want beta.irc-urls.net showing up everywhere
  match "*anything", :to => redirect("http://irc-urls.net/%{anything}"), :constraints => {:subdomain => "beta"}
  match "/", :to => redirect("http://irc-urls.net/"), :constraints => {:subdomain => "beta"}

  [:images, :videaos, :media].each do |type|
    match "/#{type}/grid/recent", :to => redirect("/#{type}/recent/grid")
  end

  devise_for :users
  resource :token, :only => ["create"]
  match '/account' => 'users#show', :as => 'account'
  match 'help/installation' => "help#installation", :as => "help_installation"

  resources :trackings
  [:url, :image_url, :video_url].each do |type|
    resources type, :path => :url, :controller => :urls, :only => :show
  end

  resources :networks, :only => :index do
    occurrences
    resources :channels, :only => :index do
      occurrences
    end
  end

  resources :caches, :only => :show

  occurrences do
    root :to => "occurrences#index"
  end

end
