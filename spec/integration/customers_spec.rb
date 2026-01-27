require "swagger_helper"

RSpec.describe "Customers API", type: :request, swagger_doc: "v1/swagger.yaml" do
  let!(:customer1) { create(:customer, name: "Ana Maria") }
  let!(:customer2) { create(:customer) }

  path "/api/v1/customers" do
    get "Lista todos os clientes" do
      description "Retorna uma lista de todos os clientes cadastrados na aplicação."
      operationId "listCustomers"
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
      description "Cria um novo cliente com os dados fornecidos."
      operationId "createCustomer"
      tags "Customers"
      consumes "application/json"
      produces "application/json"

      parameter name: :customer, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, example: "Ana Maria" },
          email: { type: :string, example: "ana.maria@example.com" },
          phone: {
            type: :string,
            description: "Telefone opcional. Aceita apenas números e caracteres comuns de telefone (+, espaços, parênteses e hífen). Será normalizado e salvo apenas com dígitos. Ex.: '+55 (85) 98683-5522' => '5585986835522'.",
            example: "+55 (85) 98683-5522",
            pattern: '^[0-9+\s\-\(\)]+$'
          }
        },
        required: %w[name email],
        example: {
          name: "Ana Maria",
          email: "ana.maria@example.com",
          phone: "+55 (85) 98683-5522"
        }
      }

      response "201", "Cliente criado" do
        schema '$ref' => '#/components/schemas/Customer'

        let(:customer) do
          {
            name: "Ana Maria",
            email: "ana.maria@example.com",
            phone: "+55 (85) 98683-5522"
          }
        end

        examples "application/json" => {
          id: 1,
          name: "Ana Maria",
          email: "ana.maria@example.com",
          phone: "5585986835522",
          created_at: "2025-12-08T15:10:17.073Z",
          updated_at: "2025-12-08T15:10:17.073Z"
        }

        run_test!
      end

      response "422", "Criação inválida" do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:customer) do
          {
            name: "Ana Maria",
            email: "",
            phone: "85999999999"
          }
        end

        examples "application/json" => {
          errors: [
            {
              errorType: ErrorTypes::FIELD_VALIDATION,
              message: "Email can't be blank"
            }
          ],
          metadata: {
            requestId: "c8f8c9c2-9dcb-4e9b-b5c2-123456789abc",
            occurredAt: "2025-01-01T12:00:00Z",
            path: "/api/v1/customers"
          }
        }

        run_test!
      end

      response "422", "Telefone inválido (contém letras)" do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:customer) do
          {
            name: "Ana Maria",
            email: "ana.maria@example.com",
            phone: "4324abc123"
          }
        end

        examples "application/json" => {
          errors: [
            {
              errorType: ErrorTypes::FIELD_VALIDATION,
              message: "Phone must contain only numbers and valid phone characters"
            }
          ],
          metadata: {
            requestId: "c8f8c9c2-9dcb-4e9b-b5c2-123456789abc",
            occurredAt: "2025-01-01T12:00:00Z",
            path: "/api/v1/customers"
          }
        }

        run_test!
      end
    end
  end

  path "/api/v1/customers/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "ID do cliente", example: 1

    get "Informações do cliente" do
      description "Retorna as informações do cliente especificado pelo ID."
      operationId "getCustomer"
      tags "Customers"
      produces "application/json"

      response "200", "Cliente encontrado" do
        schema '$ref' => '#/components/schemas/Customer'

        let(:id) { customer1.id }

        examples "application/json" => {
          id: 1,
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
          errors: [
            {
              errorType: ErrorTypes::NOT_FOUND,
              message: "Customer not found"
            }
          ],
          metadata: {
            requestId: "c8f8c9c2-9dcb-4e9b-b5c2-123456789abc",
            occurredAt: "2025-01-01T12:00:00Z",
            path: "/api/v1/customers/99999"
          }
        }

        run_test!
      end
    end

    patch "Atualiza parcialmente o cliente" do
      description "Atualiza parcialmente as informações do cliente especificado pelo ID."
      operationId "updateCustomerPartial"
      tags "Customers"
      consumes "application/json"
      produces "application/json"

      parameter name: :customer, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, example: "Jorge Campos" },
          phone: {
            type: :string,
            description: "Telefone opcional. Aceita apenas números e caracteres comuns de telefone (+, espaços, parênteses e hífen). Será normalizado e salvo apenas com dígitos.",
            example: "(85) 98683-5522",
            pattern: '^[0-9+\s\-\(\)]+$'
          }
        },
        example: {
          name: "Jorge Campos",
          phone: "(85) 98683-5522"
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
          errors: [
            {
              errorType: ErrorTypes::FIELD_VALIDATION,
              message: "Name can't be blank"
            }
          ],
          metadata: {
            requestId: "c8f8c9c2-9dcb-4e9b-b5c2-123456789abc",
            occurredAt: "2025-01-01T12:00:00Z",
            path: "/api/v1/customers/1"
          }
        }

        run_test!
      end

      response "422", "Telefone inválido (contém letras)" do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:id) { customer1.id }
        let(:customer) { { phone: "4324abc123" } }

        examples "application/json" => {
          errors: [
            {
              errorType: ErrorTypes::FIELD_VALIDATION,
              message: "Phone must contain only numbers and valid phone characters"
            }
          ],
          metadata: {
            requestId: "c8f8c9c2-9dcb-4e9b-b5c2-123456789abc",
            occurredAt: "2025-01-01T12:00:00Z",
            path: "/api/v1/customers/1"
          }
        }

        run_test!
      end
    end

    put "Atualiza completamente o cliente" do
      description "Atualiza completamente as informações do cliente especificado pelo ID."
      operationId "updateCustomerFull"
      tags "Customers"
      consumes "application/json"
      produces "application/json"

      parameter name: :customer, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, example: "Jorge Campos" },
          email: { type: :string, example: "jorge.campos@example.com" },
          phone: {
            type: :string,
            description: "Telefone opcional. Aceita apenas números e caracteres comuns de telefone (+, espaços, parênteses e hífen). Será normalizado e salvo apenas com dígitos.",
            example: "+55 (85) 98686-5522",
            pattern: '^[0-9+\s\-\(\)]+$'
          }
        },
        example: {
          name: "Jorge Campos",
          email: "jorge.campos@example.com",
          phone: "+55 (85) 98686-5522"
        }
      }

      response "200", "Cliente atualizado" do
        schema '$ref' => '#/components/schemas/Customer'

        let(:id) { customer1.id }
        let(:customer) do
          {
            name: "Jorge Campos",
            email: "jorge.campos@example.com",
            phone: "+55 (85) 98686-5522"
          }
        end

        examples "application/json" => {
          id: 1,
          name: "Jorge Campos",
          email: "jorge.campos@example.com",
          phone: "5585986865522",
          created_at: "2025-12-08T15:10:17.073Z",
          updated_at: "2025-12-08T15:10:17.073Z"
        }

        run_test!
      end

      response "422", "Atualização inválida" do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:id) { customer1.id }
        let(:customer) do
          {
            name: "Jorge Campos",
            email: "",
            phone: "85977777777"
          }
        end

        examples "application/json" => {
          errors: [
            {
              errorType: ErrorTypes::FIELD_VALIDATION,
              message: "Email can't be blank"
            }
          ],
          metadata: {
            requestId: "c8f8c9c2-9dcb-4e9b-b5c2-123456789abc",
            occurredAt: "2025-01-01T12:00:00Z",
            path: "/api/v1/customers/1"
          }
        }

        run_test!
      end

      response "422", "Telefone inválido (contém letras)" do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:id) { customer1.id }
        let(:customer) do
          {
            name: "Jorge Campos",
            email: "jorge.campos@example.com",
            phone: "4324abc123"
          }
        end

        examples "application/json" => {
          errors: [
            {
              errorType: ErrorTypes::FIELD_VALIDATION,
              message: "Phone must contain only numbers and valid phone characters"
            }
          ],
          metadata: {
            requestId: "c8f8c9c2-9dcb-4e9b-b5c2-123456789abc",
            occurredAt: "2025-01-01T12:00:00Z",
            path: "/api/v1/customers/1"
          }
        }

        run_test!
      end
    end

    delete "Deletar cliente" do
      description "Deleta o cliente especificado pelo ID."
      operationId "deleteCustomer"
      tags "Customers"

      response "204", "Cliente deletado" do
        let(:id) { customer1.id }
        run_test!
      end

      response "404", "Cliente não encontrado" do
        schema '$ref' => '#/components/schemas/ErrorResponse'
        let(:id) { 99999 }

        examples "application/json" => {
          errors: [
            {
              errorType: ErrorTypes::NOT_FOUND,
              message: "Customer not found"
            }
          ],
          metadata: {
            requestId: "c8f8c9c2-9dcb-4e9b-b5c2-123456789abc",
            occurredAt: "2025-01-01T12:00:00Z",
            path: "/api/v1/customers/99999"
          }
        }

        run_test!
      end
    end
  end
end
