DealSite::Application.routes.draw do
  resources :advertisers do
    resource :publisher
  end

  resources :deals do
    resource :advertiser
    collection do # TPP add search_deals_path
      get :search
    end
  end

  resources :publishers do
    resources :advertisers
  end

  match '/' => 'publishers#index', :as => :root
end
