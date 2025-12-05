Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get "health", to: "health#index"

      resources :customer_params
    end
  end
end
