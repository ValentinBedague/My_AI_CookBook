Rails.application.routes.draw do
  devise_for :users, sign_out_via: [:get, :post], controllers: { registrations: "users/registrations" }
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "home", to: "pages#home_visitor"

  resources :recipes, only: [:index, :new, :create, :show, :edit, :update, :destroy] do
    post 'toggle_favorite', on: :member
    member do
      get :ask_ai
      post :create_low_calories
      get :view_low_calories
    end
    collection do
      get :new_via_url
      post :create_via_url

      get :new_via_img
      post :create_via_img

      post :parse_ingredient
      post :generate_img

      get :test
    end
    member do
      delete :discard
    end
    resources :messages do
      collection do
        get :edit_portions
        post :run_edit_portions
      end
    end
  end

  resources :collections do
    resources :tags, only: [:new, :create]
  end
  resources :tags, only: [:destroy]

  resources :users, only: [:show, :edit, :update] do
    resources :restrictions, only: [:edit, :patch]
  end

end
