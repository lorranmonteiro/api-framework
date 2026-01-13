# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  config.openapi_root = Rails.root.join('swagger').to_s

  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'API REST – Sistema de Pedidos',
        version: 'v1',
        description: <<~DESC
          Documentação da API REST desenvolvida como Trabalho de Conclusão de Curso (TCC),
          com foco na aplicação de boas práticas de engenharia de software, padrões de projeto,
          padronização de erros, testes automatizados e documentação orientada a contrato (OpenAPI).
        DESC
      },
      paths: {},
      components: {
        schemas: {
          ErrorType: {
            type: :string,
            description: 'Código semântico e estável do erro',
            enum: [
              'FIELD_VALIDATION',
              'BUSINESS_VALIDATION',
              'NOT_FOUND',
              'INTERNAL_SERVER_ERROR'
            ],
            example: 'FIELD_VALIDATION'
          },

          Error: {
            type: :object,
            description: 'Representa um erro individual retornado pela API',
            properties: {
              errorType: {
                '$ref' => '#/components/schemas/ErrorType'
              },
              errorCode: {
                type: :string,
                nullable: true,
                example: 'ERROR-12345',
                description: 'Código interno opcional para rastreamento do erro'
              },
              message: {
                type: :string,
                example: "Email can't be blank",
                description: 'Mensagem descritiva do erro'
              }
            },
            required: %w[errorType message]
          },

          ErrorMetadata: {
            type: :object,
            description: 'Metadados relacionados à requisição que gerou o erro',
            properties: {
              requestId: {
                type: :string,
                example: 'c8f8c9c2-9dcb-4e9b-b5c2-123456789abc'
              },
              timestamp: {
                type: :string,
                format: :'date-time',
                example: '2025-01-01T12:00:00Z'
              },
              path: {
                type: :string,
                example: '/api/v1/customers/999'
              }
            },
            required: %w[requestId timestamp path]
          },

          ErrorResponse: {
            type: :object,
            description: 'Resposta padrão de erro da API',
            properties: {
              errors: {
                type: :array,
                minItems: 1,
                items: {
                  '$ref' => '#/components/schemas/Error'
                }
              },
              metadata: {
                '$ref' => '#/components/schemas/ErrorMetadata'
              }
            },
            required: %w[errors metadata]
          },

          Product: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              name: { type: :string, example: 'Keyboard' },
              description: {
                type: :string,
                nullable: true,
                example: 'Mechanical keyboard'
              },
              price: {
                type: :string,
                format: :float,
                example: '199.90'
              },
              created_at: { type: :string, format: :'date-time' },
              updated_at: { type: :string, format: :'date-time' }
            },
            required: %w[id name price]
          },

          Customer: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              name: { type: :string, example: 'John Doe' },
              email: { type: :string, format: :email, example: 'john@example.com' },
              phone: { type: :string, nullable: true, example: '999999999' },
              created_at: { type: :string, format: :'date-time' },
              updated_at: { type: :string, format: :'date-time' }
            },
            required: %w[id name email]
          },

          Order: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              customer_id: { type: :integer, example: 1 },
              status: { type: :string, example: 'new' },
              total_amount: { type: :string, format: :float, example: '250.00' },
              created_at: { type: :string, format: :'date-time' },
              updated_at: { type: :string, format: :'date-time' }
            },
            required: %w[id customer_id status total_amount]
          },

          OrderProduct: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              order_id: { type: :integer, example: 1 },
              product_id: { type: :integer, example: 1 },
              quantity: { type: :integer, example: 2 },
              price: { type: :string, format: :float, example: '100.00' },
              created_at: { type: :string, format: :'date-time' },
              updated_at: { type: :string, format: :'date-time' }
            },
            required: %w[id order_id product_id quantity]
          }
        }
      }
    }
  }

  config.openapi_format = :yaml
end
