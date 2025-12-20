require "swagger_helper"

RSpec.describe "OrderProducts API", type: :request, swagger_doc: "v1/swagger.yaml" do
  let!(:customer) { create(:customer) }
  let!(:order)    { create(:order, customer: customer) }
  let!(:product)  { create(:product, name: "Keyboard", price: 100) }

  let!(:order_product1) { create(:order_product, order: order, product: product, quantity: 1, price: 100) }
  let!(:order_product2) { create(:order_product, order: order, product: product, quantity: 3, price: 100) }

  path "/api/v1/order_products" do

    post "Cria um produto do pedido" do
      tags "OrderProducts"
      consumes "application/json"
      produces "application/json"

      parameter name: :order_product, in: :body, schema: {
        type: :object,
        properties: {
          order_id:   { type: :integer, example: 1 },
          product_id: { type: :integer, example: 1 },
          quantity:   { type: :integer, example: 2 },
          price:      { type: :number, format: :float, example: 100.0 }
        },
        required: %w[order_id product_id quantity],
        example: {
          order_id: 1,
          product_id: 1,
          quantity: 2,
          price: 100
        }
      }

      response "201", "Produto do pedido criado" do
        schema '$ref' => '#/components/schemas/OrderProduct'

        let(:order_product) do
          {
            order_id: order.id,
            product_id: product.id,
            quantity: 2,
            price: 100
          }
        end

        examples "application/json" => {
          id: 3,
          order_id: 1,
          product_id: 1,
          quantity: 2,
          price: "100.0",
          created_at: "2025-12-08T15:12:20.123Z",
          updated_at: "2025-12-08T15:12:20.123Z"
        }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["quantity"]).to eq(2)
          expect(json["price"]).to eq("100.0")
        end
      end

      response "422", "Produto do pedido inválido" do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:order_product) do
          {
            order_id: order.id,
            product_id: product.id,
            quantity: 0,
            price: 100
          }
        end

        examples "application/json" => {
          message: "Quantity must be greater than 0",
          internalErrorCode: "E46",
          errorType: "VALIDATION_ERROR",
          requestDetails: {
            occurredAt: "2025-01-01T12:00:00Z",
            requestId: "c8f8c9c2-9dcb-4e9b-b5c2-123456789abc",
            path: "/api/v1/order_products"
          },
          additionalErrors: []
        }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["message"]).to include("Quantity must be greater than 0")
        end
      end
    end
  end

  path "/api/v1/order_products/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "ID do produto do pedido", example: 1

    get "Informações do produto do pedido" do
      tags "OrderProducts"
      produces "application/json"

      response "200", "Produto do pedido encontrado" do
        schema '$ref' => '#/components/schemas/OrderProduct'

        let(:id) { order_product1.id }

        examples "application/json" => {
          id: 3,
          order_id: 1,
          product_id: 1,
          quantity: 2,
          price: "100.0",
          created_at: "2025-12-08T15:12:20.123Z",
          updated_at: "2025-12-08T15:12:20.123Z"
        }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["id"]).to eq(order_product1.id)
        end
      end

      response "404", "Produto do pedido não encontrado" do
        schema '$ref' => '#/components/schemas/ErrorResponse'
        let(:id) { 99999 }

        examples "application/json" => {
          message: "Order Product not found",
          internalErrorCode: "E19",
          errorType: "NOT_FOUND_ERROR",
          requestDetails: {
            occurredAt: "2025-01-01T12:00:00Z",
            requestId: "c8f8c9c2-9dcb-4e9b-b5c2-123456789abc",
            path: "/api/v1/order_products/99999"
          },
          additionalErrors: []
        }

        run_test!
      end
    end

    patch "Atualizar produto do pedido" do
      tags "OrderProducts"
      consumes "application/json"
      produces "application/json"

      parameter name: :order_product, in: :body, schema: {
        type: :object,
        properties: {
          quantity: { type: :integer, example: 5 },
          price:    { type: :number, format: :float, example: 100.0 }
        }
      }

      response "200", "Produto do pedido atualizado" do
        schema '$ref' => '#/components/schemas/OrderProduct'

        let(:id) { order_product1.id }
        let(:order_product) { { quantity: 5 } }

        examples "application/json" => {
          id: 3,
          order_id: 1,
          product_id: 1,
          quantity: 2,
          price: "100.0",
          created_at: "2025-12-08T15:12:20.123Z",
          updated_at: "2025-12-08T15:12:20.123Z"
        }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["quantity"]).to eq(5)
        end
      end

      response "422", "Atualização inválida" do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:id) { order_product1.id }
        let(:order_product) { { quantity: 0 } }

        examples "application/json" => {
          message: "Quantity must be greater than 0",
          internalErrorCode: "E46",
          errorType: "VALIDATION_ERROR",
          requestDetails: {
            occurredAt: "2025-01-01T12:00:00Z",
            requestId: "c8f8c9c2-9dcb-4e9b-b5c2-123456789abc",
            path: "/api/v1/order_products"
          },
          additionalErrors: []
        }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["message"]).to include("Quantity must be greater than 0")
        end
      end
    end

    delete "Deleta o produto do pedido" do
      tags "OrderProducts"

      response "204", "Produto do pedido deletado" do
        let(:id) { order_product1.id }
        run_test!
      end

      response "404", "Produto do pedido não encontrado" do
        schema '$ref' => '#/components/schemas/ErrorResponse'
        let(:id) { 99999 }

        examples "application/json" => {
          message: "Order Product not found",
          internalErrorCode: "E19",
          errorType: "NOT_FOUND_ERROR",
          requestDetails: {
            occurredAt: "2025-01-01T12:00:00Z",
            requestId: "c8f8c9c2-9dcb-4e9b-b5c2-123456789abc",
            path: "/api/v1/order_products/99999"
          },
          additionalErrors: []
        }

        run_test!
      end
    end
  end

  path "/api/v1/orders/{id}/products" do
    parameter name: :id, in: :path, type: :integer, description: "ID do pedido", example: 1

    get "Lista produtos do pedido" do
      tags "OrderProducts"
      produces "application/json"

      response "200", "Produtos encontrados" do
        schema type: :array,
               items: { '$ref' => '#/components/schemas/Product' }

        let(:id) { order.id }

        examples "application/json" => [
          {
            id: 1,
            order_id: 1,
            product_id: 1,
            quantity: 1,
            price: "100.0",
            created_at: "2025-12-08T15:10:17.073Z",
            updated_at: "2025-12-08T15:10:17.073Z"
          },
          {
            id: 2,
            order_id: 1,
            product_id: 2,
            quantity: 1,
            price: "200.0",
            created_at: "2025-12-08T15:10:17.073Z",
            updated_at: "2025-12-08T15:10:17.073Z"
          }
        ]

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json.first["name"]).to eq("Keyboard")
        end
      end

      response "404", "Pedido não encontrado" do
        schema '$ref' => '#/components/schemas/ErrorResponse'
        let(:id) { 99999 }

        examples "application/json" => {
          message: "Customer not found",
          internalErrorCode: "E42",
          errorType: "NOT_FOUND_ERROR",
          requestDetails: {
            occurredAt: "2025-01-01T12:00:00Z",
            requestId: "c8f8c9c2-9dcb-4e9b-b5c2-123456789abc",
            path: "/api/v1/customer/99999/orders"
          },
          additionalErrors: []
        }

        run_test!
      end
    end
  end
end
