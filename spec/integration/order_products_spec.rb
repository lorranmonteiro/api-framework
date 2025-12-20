require "swagger_helper"

RSpec.describe "OrderProducts API", type: :request, swagger_doc: "v1/swagger.yaml" do
  let!(:customer) { create(:customer) }
  let!(:order)    { create(:order, customer: customer) }
  let!(:product)  { create(:product, name: "Keyboard", price: 100) }

  let!(:order_product1) { create(:order_product, order: order, product: product, quantity: 1, price: 100) }
  let!(:order_product2) { create(:order_product, order: order, product: product, quantity: 3, price: 100) }

  path "/api/v1/order_products" do

    post "Create order product" do
      tags "OrderProducts"
      consumes "application/json"
      produces "application/json"

      parameter name: :order_product, in: :body, schema: {
        type: :object,
        properties: {
          order_id:   { type: :integer },
          product_id:{ type: :integer },
          quantity:   { type: :integer },
          price:      { type: :number, format: :float }
        },
        required: %w[order_id product_id quantity]
      }

      response "201", "order product created" do
        schema '$ref' => '#/components/schemas/OrderProduct'

        let(:order_product) do
          {
            order_id: order.id,
            product_id: product.id,
            quantity: 2,
            price: 100
          }
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["quantity"]).to eq(2)
        end
      end

      response "422", "invalid order product" do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:order_product) do
          {
            order_id: order.id,
            product_id: product.id,
            quantity: 0,
            price: 100
          }
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["message"]).to include("Quantity must be greater than 0")
        end
      end
    end
  end

  path "/api/v1/order_products/{id}" do
    parameter name: :id, in: :path, type: :integer

    get "Show order product" do
      tags "OrderProducts"
      produces "application/json"

      response "200", "order product found" do
        schema '$ref' => '#/components/schemas/OrderProduct'

        let(:id) { order_product1.id }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["id"]).to eq(order_product1.id)
        end
      end

      response "404", "order product not found" do
        schema '$ref' => '#/components/schemas/ErrorResponse'
        let(:id) { 99999 }
        run_test!
      end
    end

    patch "Update order product" do
      tags "OrderProducts"
      consumes "application/json"
      produces "application/json"

      parameter name: :order_product, in: :body, schema: {
        type: :object,
        properties: {
          quantity: { type: :integer },
          price:    { type: :number, format: :float }
        }
      }

      response "200", "order product updated" do
        schema '$ref' => '#/components/schemas/OrderProduct'

        let(:id) { order_product1.id }
        let(:order_product) { { quantity: 5 } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["quantity"]).to eq(5)
        end
      end

      response "422", "invalid update" do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:id) { order_product1.id }
        let(:order_product) { { quantity: 0 } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["message"]).to include("Quantity must be greater than 0")
        end
      end
    end

    delete "Delete order product" do
      tags "OrderProducts"

      response "204", "order product deleted" do
        let(:id) { order_product1.id }
        run_test!
      end

      response "404", "order product not found" do
        schema '$ref' => '#/components/schemas/ErrorResponse'
        let(:id) { 99999 }
        run_test!
      end
    end
  end

  path "/api/v1/orders/{id}/products" do
    parameter name: :id, in: :path, type: :integer

    get "List products by order" do
      tags "OrderProducts"
      produces "application/json"

      response "200", "products found" do
        schema type: :array,
               items: { '$ref' => '#/components/schemas/Product' }

        let(:id) { order.id }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json.first["name"]).to eq("Keyboard")
        end
      end

      response "404", "order not found" do
        schema '$ref' => '#/components/schemas/ErrorResponse'
        let(:id) { 99999 }
        run_test!
      end
    end
  end
end
