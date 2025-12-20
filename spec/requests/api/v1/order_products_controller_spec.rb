require 'rails_helper'

RSpec.describe "Api::V1::OrderProductsController", type: :request do
  let!(:customer) { create(:customer) }
  let!(:order)    { create(:order, customer: customer) }
  let!(:product)  { create(:product, name: "Keyboard") }

  let!(:order_product1) { create(:order_product, order: order, product: product, quantity: 1, price: 100) }
  let!(:order_product2) { create(:order_product, order: order, product: product, quantity: 3, price: 100) }

  let(:base_url) { "/api/v1/order_products" }

  describe "GET /api/v1/order_products/:id" do
    it "returns the order_product" do
      get "#{base_url}/#{order_product1.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json["id"]).to eq(order_product1.id)
    end
  end

  describe "POST /api/v1/order_products" do
    let(:valid_params) do
      {
        order_product: {
          order_id: order.id,
          product_id: product.id,
          quantity: 2,
          price: 100
        }
      }
    end

    let(:invalid_params) do
      {
        order_product: {
          order_id: order.id,
          product_id: product.id,
          quantity: 0,
          price: 100
        }
      }
    end

    it "creates an order_product with valid params" do
      post base_url, params: valid_params

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)

      expect(json["quantity"]).to eq(2)
    end

    it "returns error with invalid params" do
      post base_url, params: invalid_params

      expect(response).to have_http_status(:unprocessable_content)
      json = JSON.parse(response.body)

      expect(json["message"]).to include("Quantity must be greater than 0")
    end
  end

  describe "PATCH /api/v1/order_products/:id" do
    it "updates an order_product" do
      patch "#{base_url}/#{order_product1.id}", params: {
        order_product: { quantity: 5 }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json["quantity"]).to eq(5)
    end

    it "returns error on invalid update" do
      patch "#{base_url}/#{order_product1.id}", params: {
        order_product: { quantity: 0 }
      }

      expect(response).to have_http_status(:unprocessable_content)
      json = JSON.parse(response.body)

      expect(json["message"]).to include("Quantity must be greater than 0")
    end
  end

  describe "DELETE /api/v1/order_products/:id" do
    it "deletes an order_product" do
      delete "#{base_url}/#{order_product1.id}"

      expect(response).to have_http_status(:no_content)
      expect(OrderProduct.find_by(id: order_product1.id)).to be_nil
    end
  end

  describe "GET /api/v1/orders/:id/products" do
    it "returns products from a specific order" do
      get "/api/v1/orders/#{order.id}/products"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json.first["name"]).to eq("Keyboard")
    end
  end
end
