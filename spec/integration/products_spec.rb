require "swagger_helper"

RSpec.describe "Products API", type: :request, swagger_doc: "v1/swagger.yaml" do
  let!(:product1) { create(:product, name: "Product A", price: 10.50) }
  let!(:product2) { create(:product, price: 20.00) }

  path "/api/v1/products" do
    get "Lista todos os produtos" do
      tags "Products"
      produces "application/json"

      response "200", "Produtos encontrados" do
        schema type: :array,
               items: { '$ref' => '#/components/schemas/Product' }

        examples "application/json" => [
          {
            id: 1,
            name: "Laranja",
            description: "Bem docinha",
            price: "10.50",
            created_at: "2025-12-08T15:10:17.073Z",
            updated_at: "2025-12-08T15:10:17.073Z"
          },
          {
            id: 2,
            name: "Banana prata",
            description: "Bem madurinha",
            price: "20.00",
            created_at: "2025-12-08T15:12:20.123Z",
            updated_at: "2025-12-08T15:12:20.123Z"
          }
        ]

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json.size).to eq(2)
          expect(json.first["name"]).to eq("Product A")
        end
      end
    end

    post "Cria um produto" do
      tags "Products"
      consumes "application/json"
      produces "application/json"

      parameter name: :product, in: :body, schema: {
        type: :object,
        properties: {
          name:        { type: :string },
          description: { type: :string },
          price:       { type: :number, format: :float }
        },
        required: %w[name price],
        example: {
          name: "Laranja",
          description: "Bem docinha",
          price: 10.0
        }
      }

      response "201", "Produto criado" do
        schema '$ref' => '#/components/schemas/Product'

        let(:product) do
          {
            name: "Laranja",
            description: "Bem docinha",
            price: 15.99
          }
        end

        examples "application/json" => {
          id: 1,
          name: "Laranja",
          description: "Bem docinha",
          price: "15.99",
          created_at: "2025-12-08T15:10:17.073Z",
          updated_at: "2025-12-08T15:10:17.073Z"
        }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["name"]).to eq("Laranja")
          expect(json["price"]).to eq("15.99")
        end
      end

      response "422", "Produto inválido" do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:product) do
          {
            name: "",
            price: -10
          }
        end

        examples "application/json" => {
          message: "Name can't be blank",
          internalErrorCode: "E25",
          errorType: "VALIDATION_ERROR",
          requestDetails: {
            occurredAt: "2025-01-01T12:00:00Z",
            requestId: "c8f8c9c2-9dcb-4e9b-b5c2-123456789abc",
            path: "/api/v1/products"
          },
          additionalErrors: []
        }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["message"]).to be_an(Array)
          expect(json["message"]).to include("Name can't be blank")
          expect(json["message"]).to include("Price must be greater than 0")
        end
      end
    end
  end

  path "/api/v1/products/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "ID do produto", example: 1

    get "Informações do produto" do
      tags "Products"
      produces "application/json"

      response "200", "Produto encontrado" do
        schema '$ref' => '#/components/schemas/Product'

        let(:id) { product1.id }

        examples "application/json" => {
          id: 1,
          name: "Laranja",
          description: "Bem docinha",
          price: "15.99",
          created_at: "2025-12-08T15:10:17.073Z",
          updated_at: "2025-12-08T15:10:17.073Z"
        }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["name"]).to eq("Product A")
        end
      end

      response "404", "Produto não encontrado" do
        schema '$ref' => '#/components/schemas/ErrorResponse'
        let(:id) { 99999 }

        examples "application/json" => {
          message: "Product not found",
          internalErrorCode: "E71",
          errorType: "NOT_FOUND_ERROR",
          requestDetails: {
            occurredAt: "2025-01-01T12:00:00Z",
            requestId: "c8f8c9c2-9dcb-4e9b-b5c2-123456789abc",
            path: "/api/v1/products/99999"
          },
          additionalErrors: []
        }

        run_test!
      end
    end

    patch "Atualiza parcialmente um produto" do
      tags "Products"
      consumes "application/json"
      produces "application/json"

      parameter name: :product, in: :body, schema: {
        type: :object,
        properties: {
          name:  { type: :string },
          price: { type: :number, format: :float }
        },
        example: {
          name: "Laranja Pera"
        }
      }

      response "200", "Produto atualizado" do
        schema '$ref' => '#/components/schemas/Product'

        let(:id) { product1.id }
        let(:product) { { name: "Laranja Pera" } }

        examples "application/json" => {
          id: 1,
          name: "Laranja",
          description: "Mais doce ainda",
          price: "5.0",
          created_at: "2025-12-08T15:10:17.073Z",
          updated_at: "2025-12-08T15:10:17.073Z"
        }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["name"]).to eq("Laranja Pera")
        end
      end

      response "422", "Atualização inválida" do
        schema '$ref' => '#/components/schemas/ErrorResponse'
        let(:id) { product1.id }
        let(:product) { { price: -50 } }

        examples "application/json" => {
          message: "Price must be greater than 0",
          internalErrorCode: "E27",
          errorType: "VALIDATION_ERROR",
          requestDetails: {
            occurredAt: "2025-01-01T12:00:00Z",
            requestId: "c8f8c9c2-9dcb-4e9b-b5c2-123456789abc",
            path: "/api/v1/products/99999"
          },
          additionalErrors: []
        }

        run_test!
      end
    end

    put "Atualiza completamente um produto" do
      tags "Products"
      consumes "application/json"
      produces "application/json"

      parameter name: :product, in: :body, schema: {
        type: :object,
        properties: {
          name:  { type: :string },
          price: { type: :number, format: :float }
        },
        example: {
          name: "Laranja Pera",
          description: "Mais doce ainda",
          price: 5.0
        }
      }

      response "200", "Produto atualizado" do
        schema '$ref' => '#/components/schemas/Product'

        let(:id) { product1.id }
        let(:product) { { name: "Laranja Pera", description: "Mais doce ainda", price: 5.0 } }

        examples "application/json" => {
          id: 1,
          name: "Laranja",
          description: "Mais doce ainda",
          price: "5.0",
          created_at: "2025-12-08T15:10:17.073Z",
          updated_at: "2025-12-08T15:10:17.073Z"
        }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["name"]).to eq("Laranja Pera")
          expect(json["description"]).to eq("Mais doce ainda")
          expect(json["price"]).to eq("5.0")
        end
      end

      response "422", "Atualização inválida" do
        schema '$ref' => '#/components/schemas/ErrorResponse'
        let(:id) { product1.id }
        let(:product) { { name: "Laranja Pera", description: "Mais doce ainda", price: 0.00 } }

        examples "application/json" => {
          message: "Price must be greater than 0",
          internalErrorCode: "E83",
          errorType: "VALIDATION_ERROR",
          requestDetails: {
            occurredAt: "2025-01-01T12:00:00Z",
            requestId: "c8f8c9c2-9dcb-4e9b-b5c2-123456789abc",
            path: "/api/v1/products/99999"
          },
          additionalErrors: []
        }

        run_test!
      end
    end

    delete "Deleta um produto" do
      tags "Products"

      response "204", "Produto deletado" do
        let(:id) { product1.id }
        run_test!
      end

      response "404", "Produto não encontrado" do
        schema '$ref' => '#/components/schemas/ErrorResponse'
        let(:id) { 99999 }

        examples "application/json" => {
          message: "Product not found",
          internalErrorCode: "E23",
          errorType: "NOT_FOUND_ERROR",
          requestDetails: {
            occurredAt: "2025-01-01T12:00:00Z",
            requestId: "c8f8c9c2-9dcb-4e9b-b5c2-123456789abc",
            path: "/api/v1/products/99999"
          },
          additionalErrors: []
        }

        run_test!
      end
    end
  end
end
