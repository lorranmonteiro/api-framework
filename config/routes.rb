Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get "customer/:customer_id/orders", to: "orders#customer_orders"

      resources :customers
      resources :products
      resources :orders
    end
  end
end
