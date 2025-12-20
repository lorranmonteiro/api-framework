require "swagger_helper"

RSpec.describe "Customers API", type: :request, swagger_doc: "v1/swagger.yaml" do
  let!(:customer1) { create(:customer, name: "Ana Maria") }
  let!(:customer2) { create(:customer) }

  path "/api/v1/customers" do
    get "Lista todos os clientes" do
      tags "Customers"
      produces "application/json"

      response "200", "Clientes encontrados" do
        schema type: :array,
               items: { '$ref' => '#/components/schemas/Customer' }

        examples "application/json" => [
          {
            id: 1,
            name: "João Victor",
            email: "joao.victor@example.com",
            phone: "85999999999",
            created_at: "2025-12-08T15:10:17.073Z",
            updated_at: "2025-12-08T15:10:17.073Z"
          },
          {
            id: 2,
            name: "Ana Maria",
            email: "ana.maria@example.com",
            phone: "85988888888",
            created_at: "2025-12-08T15:12:20.123Z",
            updated_at: "2025-12-08T15:12:20.123Z"
          }
        ]

        run_test!
      end
    end

    post "Cria um novo cliente" do
      tags "Customers"
      consumes "application/json"
      produces "application/json"

      parameter name: :customer, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, example: "Ana Maria" },
          email: { type: :string, example: "ana.maria@example.com" },
          phone: { type: :string, example: "85999999999" }
        },
        required: %w[name email],
        example: {
          name: "Ana Maria",
          email: "ana.maria@example.com",
          phone: "85999999999"
        }
      }

      response "201", "Cliente criado" do
        schema '$ref' => '#/components/schemas/Customer'

        let(:customer) do
          {
            name: "Ana Maria",
            email: "ana.maria@example.com",
            phone: "85999999999"
          }
        end

        examples "application/json" => {
            id: 1,
            name: "Ana Maria",
            email: "ana.maria@example.com",
            phone: "85999999999",
            created_at: "2025-12-08T15:10:17.073Z",
            updated_at: "2025-12-08T15:10:17.073Z"
        }

        run_test!
      end

      response "422", "Atualização inválida" do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:customer) do
          {
            name: "Ana Maria",
            email: "",
            phone: "85999999999"
          }
        end

        examples "application/json" => {
          message: "Email can't be blank",
          internalErrorCode: "E4",
          errorType: "VALIDATION_ERROR",
          requestDetails: {
            occurredAt: "2025-01-01T12:00:00Z",
            requestId: "c8f8c9c2-9dcb-4e9b-b5c2-123456789abc",
            path: "/api/v1/customers"
          },
          additionalErrors: []
        }

        run_test!
      end
    end
  end

  path "/api/v1/customers/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "ID do cliente", example: 1

    get "Informações do cliente" do
      tags "Customers"
      produces "application/json"

      response "200", "Cliente encontrado" do
        schema '$ref' => '#/components/schemas/Customer'

        let(:id) { customer1.id }

        examples "application/json" => {
          id: id,
          name: "Ana Maria",
          email: "ana.maria@example.com",
          phone: "85988888888",
          created_at: "2025-12-08T15:10:17.073Z",
          updated_at: "2025-12-08T15:10:17.073Z"
        }

        run_test!
      end

      response "404", "Cliente não encontrado" do
        schema '$ref' => '#/components/schemas/ErrorResponse'
        let(:id) { 99999 }

        examples "application/json" => {
          message: "Customer not found",
          internalErrorCode: "E10",
          errorType: "NOT_FOUND_ERROR",
          requestDetails: {
            occurredAt: "2025-01-01T12:00:00Z",
            requestId: "c8f8c9c2-9dcb-4e9b-b5c2-123456789abc",
            path: "/api/v1/customers/99999"
          },
          additionalErrors: []
        }

        run_test!
      end
    end

    patch "Atualiza parcialmente o cliente" do
      tags "Customers"
      consumes "application/json"
      produces "application/json"

      parameter name: :customer, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, example: "Jorge Campos" }
        },
        example: {
          name: "Jorge Campos"
        }
      }

      response "200", "Cliente atualizado" do
        schema '$ref' => '#/components/schemas/Customer'

        let(:id) { customer1.id }
        let(:customer) { { name: "Jorge Campos" } }

        examples "application/json" => {
          id: 1,
          name: "Jorge Campos",
          email: "ana.maria@example.com",
          phone: "85988888888",
          created_at: "2025-12-08T15:10:17.073Z",
          updated_at: "2025-12-08T15:10:17.073Z"
        }

        run_test!
      end

      response "422", "Atualização inválida" do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:id) { customer1.id }
        let(:customer) { { name: "" } }

        examples "application/json" => {
          message: "Name can't be blank",
          internalErrorCode: "E89",
          errorType: "VALIDATION_ERROR",
          requestDetails: {
            occurredAt: "2025-01-01T12:00:00Z",
            requestId: "c8f8c9c2-9dcb-4e9b-b5c2-123456789abc",
            path: "/api/v1/customers/1"
          },
          additionalErrors: []
        }

        run_test!
      end
    end

    put "Atualiza completamente o cliente" do
      tags "Customers"
      consumes "application/json"
      produces "application/json"

      parameter name: :customer, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, example: "Jorge Campos" },
          email: { type: :string, example: "jorge.campos@example.com" },
          phone: { type: :string, example: "85977777777" }
        },
        example: {
          name: "Jorge Campos",
          email: "jorge.campos@example.com",
          phone: "85977777777"
        }
      }

      response "200", "Cliente atualizado" do
        schema '$ref' => '#/components/schemas/Customer'

        let(:id) { customer1.id }
        let(:customer) { { name: "Jorge Campos", email: "jorge.campos@example.com", phone: "85977777777" } }

        examples "application/json" => {
          id: 1,
          name: "Jorge Campos",
          email: "jorge.campos@example.com",
          phone: "85977777777",
          created_at: "2025-12-08T15:10:17.073Z",
          updated_at: "2025-12-08T15:10:17.073Z"
        }

        run_test!
      end

      response "422", "Atualização inválida" do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:id) { customer1.id }
        let(:customer) { { name: "Jorge Campos", email: "", phone: "85977777777" } }

        examples "application/json" => {
          message: "Email can't be blank",
          internalErrorCode: "ERR_CUSTOMER_EMAIL_BLANK",
          errorType: "VALIDATION_ERROR",
          requestDetails: {
            occurredAt: "2025-01-01T12:00:00Z",
            requestId: "c8f8c9c2-9dcb-4e9b-b5c2-123456789abc",
            path: "/api/v1/customers/1"
          },
          additionalErrors: []
        }

        run_test!
      end
    end

    delete "Deletar cliente" do
      tags "Customers"

      response "204", "Cliente deletado" do
        let(:id) { customer1.id }
        run_test!
      end

      response "404", "Cliente não encontrado" do
        schema '$ref' => '#/components/schemas/ErrorResponse'
        let(:id) { 99999 }

        examples "application/json" => {
          message: "Customer not found",
          internalErrorCode: "E11",
          errorType: "NOT_FOUND_ERROR",
          requestDetails: {
            occurredAt: "2025-01-01T12:00:00Z",
            requestId: "c8f8c9c2-9dcb-4e9b-b5c2-123456789abc",
            path: "/api/v1/customers/99999"
          },
          additionalErrors: []
        }

        run_test!
      end
    end
  end
end
