require "swagger_helper"

RSpec.describe "Orders API", type: :request, swagger_doc: "v1/swagger.yaml" do
  let!(:customer) { create(:customer) }
  let!(:order1)   { create(:order, customer: customer, status: "New", total_amount: 100) }
  let!(:order2)   { create(:order, customer: customer, status: "In progress", total_amount: 200) }

  path "/api/v1/orders" do
    get "Lista todos os pedidos" do
      tags "Orders"
      produces "application/json"

      response "200", "Pedidos encontrados" do
        schema type: :array,
               items: { '$ref' => '#/components/schemas/Order' }

        examples "application/json" => [
          {
            id: 1,
            customer_id: 1,
            status: "New",
            total_amount: 100.0,
            created_at: "2025-12-08T15:10:17.073Z",
            updated_at: "2025-12-08T15:10:17.073Z"
          },
          {
            id: 2,
            customer_id: 1,
            status: "In progress",
            total_amount: 200.0,
            created_at: "2025-12-08T15:12:20.123Z",
            updated_at: "2025-12-08T15:12:20.123Z"
          }
        ]

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json.size).to eq(2)
          expect(json.first["total_amount"].to_f).to eq(100.0)
        end
      end
    end

    post "Cria um pedido" do
      tags "Orders"
      consumes "application/json"
      produces "application/json"

      parameter name: :order, in: :body, schema: {
        type: :object,
        properties: {
          customer_id: { type: :integer, example: 1 },
          status:      { type: :string, enum: ["New", "In progress", "Done"], example: "New" },
          total_amount:{ type: :number, format: :float, example: 100.0 }
        },
        required: %w[customer_id status total_amount],
        example: {
          customer_id: 1,
          status: "New",
          total_amount: 100.0
        }
      }

      response "201", "Pedido criado" do
        schema '$ref' => '#/components/schemas/Order'

        let(:order) do
          {
            customer_id: customer.id,
            status: "New",
            total_amount: 50
          }
        end

        examples "application/json" => {
            id: 1,
            customer_id: 1,
            status: "New",
            total_amount: 100.0,
            created_at: "2025-12-08T15:10:17.073Z",
            updated_at: "2025-12-08T15:10:17.073Z"
        }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["status"]).to eq("new_order")
          expect(json["total_amount"].to_f).to eq(50.0)
        end
      end

      response "422", "Pedido inválido" do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:order) do
          {
            customer_id: nil,
            status: ""
          }
        end

        examples "application/json" => {
          message: "Customer can't be blank",
          internalErrorCode: "E40",
          errorType: "VALIDATION_ERROR",
          requestDetails: {
            occurredAt: "2025-01-01T12:00:00Z",
            requestId: "c8f8c9c2-9dcb-4e9b-b5c2-123456789abc",
            path: "/api/v1/orders"
          },
          additionalErrors: []
        }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["message"]).to be_an(Array)
          expect(json["message"]).to include("Customer must exist")
          expect(json["message"]).to include("Status can't be blank")
        end
      end
    end
  end

  path "/api/v1/orders/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "ID do pedido", example: 1

    get "Informações do pedido" do
      tags "Orders"
      produces "application/json"

      response "200", "Pedido encontrado" do
        schema '$ref' => '#/components/schemas/Order'

        let(:id) { order1.id }

        examples "application/json" => {
          id: 1,
          customer_id: 1,
          status: "New",
          total_amount: 100.0,
          created_at: "2025-12-08T15:10:17.073Z",
          updated_at: "2025-12-08T15:10:17.073Z"
        }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["total_amount"].to_f).to eq(100.0)
        end
      end

      response "404", "Pedido não encontrado" do
        schema '$ref' => '#/components/schemas/ErrorResponse'
        let(:id) { 99999 }

        examples "application/json" => {
          message: "Order not found",
          internalErrorCode: "E39",
          errorType: "NOT_FOUND_ERROR",
          requestDetails: {
            occurredAt: "2025-01-01T12:00:00Z",
            requestId: "c8f8c9c2-9dcb-4e9b-b5c2-123456789abc",
            path: "/api/v1/orders/99999"
          },
          additionalErrors: []
        }

        run_test!
      end
    end

    patch "Atualiza um pedido" do
      tags "Orders"
      consumes "application/json"
      produces "application/json"

      parameter name: :order, in: :body, schema: {
        type: :object,
        properties: {
          status:       { type: :string, enum: ["New", "In progress", "Done"], example: "Done" },
        },
        example: {
          status: "Done"
        }
      }

      response "200", "Pedido atualizado" do
        schema '$ref' => '#/components/schemas/Order'

        let(:id) { order1.id }
        let(:order) { { status: "Done" } }

        examples "application/json" => {
          id: 1,
          customer_id: 1,
          status: "Done",
          total_amount: 100.0,
          created_at: "2025-12-08T15:10:17.073Z",
          updated_at: "2025-12-08T15:10:17.073Z"
        }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["status"]).to eq("done")
        end
      end

      response "422", "Atualização inválida" do
        schema '$ref' => '#/components/schemas/ErrorResponse'
        let(:id) { order1.id }
        let(:order) { { status: nil } }

        examples "application/json" => {
          message: "Status can't be blank",
          internalErrorCode: "E43",
          errorType: "VALIDATION_ERROR",
          requestDetails: {
            occurredAt: "2025-01-01T12:00:00Z",
            requestId: "c8f8c9c2-9dcb-4e9b-b5c2-123456789abc",
            path: "/api/v1/orders/99999"
          },
          additionalErrors: []
        }

        run_test!
      end
    end

    delete "Deleta um pedido" do
      tags "Orders"

      response "204", "Pedido deletado" do
        let(:id) { order1.id }
        run_test!
      end

      response "404", "Pedido não encontrado" do
        schema '$ref' => '#/components/schemas/ErrorResponse'
        let(:id) { 99999 }

        examples "application/json" => {
          message: "Order not found",
          internalErrorCode: "ERR_ORDER_NOT_FOUND",
          errorType: "NOT_FOUND_ERROR",
          requestDetails: {
            occurredAt: "2025-01-01T12:00:00Z",
            requestId: "c8f8c9c2-9dcb-4e9b-b5c2-123456789abc",
            path: "/api/v1/orders/99999"
          },
          additionalErrors: []
        }

        run_test!
      end
    end
  end

  path "/api/v1/customer/{customer_id}/orders" do
    parameter name: :customer_id, in: :path, type: :integer, description: "ID do cliente", example: 1

    get "Lista os pedidos de um cliente" do
      tags "Orders"
      produces "application/json"

      response "200", "Pedidos encontrados" do
        schema type: :array,
               items: { '$ref' => '#/components/schemas/Order' }

        let(:customer_id) { customer.id }

        examples "application/json" => [
          {
            id: 1,
            customer_id: 1,
            status: "New",
            total_amount: 100.0,
            created_at: "2025-12-08T15:10:17.073Z",
            updated_at: "2025-12-08T15:10:17.073Z"
          },
          {
            id: 2,
            customer_id: 1,
            status: "In progress",
            total_amount: 200.0,
            created_at: "2025-12-08T15:12:20.123Z",
            updated_at: "2025-12-08T15:12:20.123Z"
          }
        ]

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json.size).to eq(2)
          expect(json.first["customer_id"]).to eq(customer.id)
        end
      end

      response "404", "Cliente não encontrado" do
        schema '$ref' => '#/components/schemas/ErrorResponse'
        let(:customer_id) { 99999 }

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
