Cobalto::Application.routes.draw do
  devise_for :users

  resources :requests
  resources :users do
    member do
      put :activate
      get :resend_code
    end
  end

  root :to => "home#index"
  match '/about', :to => "home#about", :as => :about
end
