Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  namespace :api do
    namespace :v1 do
      resources :customers
      resources :products
      resources :orders
      resources :order_products

      get "customer/:customer_id/orders", to: "orders#customer_orders"
      get "/orders/:id/products", to: "order_products#products_by_order"
    end
  end
end
