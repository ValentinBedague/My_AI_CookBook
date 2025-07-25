Rails.application.routes.draw do
  devise_for :users, sign_out_via: [:get, :post], controllers: { registrations: "users/registrations" }
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "home", to: "pages#home_visitor"

  resources :recipes, only: [:index, :new, :create, :show, :edit, :update, :destroy] do
    member do
      get :ask_ai

      post :create_low_calories
      get :view_low_calories
      patch :update_low_calories

      post :create_pairing_drinks
      get :view_pairing_drinks

      delete :discard
      post :toggle_favorite

      get :choice_change_portions
      post :change_portions
      get :view_change_portions
      patch :update_change_portions
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
    resources :messages do
      collection do
        get :edit_portions
        post :run_edit_portions
      end
    end
    resources :ingredients do
      member do
      end
      collection do
        post :swap_ingredients
        patch :update_swap_ingredients
        get :view_swap_ingredients
        get :choice_swap_ingredients
      end
    end
  end

  resources :collections do
    member do
      post :toggle_favorite
    end

    resources :tags, only: [:new, :create]
    member do
      delete :discard
    end
  end
  resources :tags, only: [:destroy]

  resources :users, only: [:show, :edit, :update] do
    resources :restrictions, only: [:edit, :patch]
  end

end
