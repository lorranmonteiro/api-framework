# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  config.openapi_root = Rails.root.join('swagger').to_s

  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      servers: [
        {
          url: 'https://api-framework.onrender.com',
          description: 'Playground API Server'
        },
        {
          url: 'http://localhost:3000',
          description: 'Local development server'
        }
      ],
      tags: [
        { name: 'Customers', description: 'Operations related to Customers' },
        { name: 'OrderProducts', description: 'Operations related to OrderProducts' },
        { name: 'Orders', description: 'Operations related to Orders' },
        { name: 'Products', description: 'Operations related to Products' }
      ],
      externalDocs: {
        description: 'Repositório do projeto no Github',
        url: 'https://github.com/lorranmonteiro/api-rest-error-handling'
      },
      info: {
        title: 'Padronização de respostas de erro em APIs REST',
        version: '1.0.0',
        contact: {
          name: 'Lorran Monteiro',
          email: 'lorrandec@gmail.com'
        },
        description: <<~DESC
          Esta API foi desenvolvida como parte de um Trabalho de Conclusão de Curso (TCC) em Engenharia de Software,
          com foco na análise crítica de padrões de resposta de erro em APIs REST.

          Motivação:
          A literatura recomenda o RFC 7807 (Problem Details for HTTP APIs), mas na prática muitas APIs populares
          adotam formatos próprios por limitações do RFC — principalmente para representar múltiplos erros e
          simplificar o consumo por aplicações cliente. Este projeto implementa e documenta um padrão unificado
          inspirado na literatura e em práticas de mercado.

          Como usar esta documentação:
          - Abra um endpoint e clique em "Try it out" ou "Test request" para executar requisições diretamente no navegador, ajuste os parâmetros e clique em "Execute" ou "Run".
          - Use os exemplos de payload para simular casos de sucesso e falha (422, 404, 500).
          - Para observar múltiplos erros, envie campos inválidos/ausentes em endpoints de criação/atualização.
          - Todas as falhas seguem o mesmo contrato: "errors[]" (lista de erros) + "metadata" (dados da requisição).

          Observação:
          Esta API não possui autenticação/autorização por escolha de escopo, mantendo o foco no contrato de erros,
          testes automatizados e documentação orientada a contrato (OpenAPI).
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
              occurredAt: {
                type: :string,
                format: :'date-time',
                example: '2025-01-01T12:00:00Z'
              },
              path: {
                type: :string,
                example: '/api/v1/customers/999'
              }
            },
            required: %w[requestId occurredAt path]
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
                format: :decimal,
                example: '199.99'
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
              total_amount: { type: :string, format: :decimal, example: '250.00' },
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
              price: { type: :string, format: :decimal, example: '100.00' },
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
