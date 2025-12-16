# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  config.openapi_root = Rails.root.join('swagger').to_s

  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Documentação API REST',
        version: 'v1',
        description: 'Esta é a documentação da API REST para o Trabalho de Conclusão de Curso (TCC), voltado para análise de proposta de padrão de projeto de software. A API oferece endpoints para gerenciar recursos relacionados ao sistema desenvolvido, permitindo operações CRUD e outras funcionalidades essenciais, seguindo as melhores práticas de desenvolvimento de software.'
      },
      paths: {},
      components: {
        schemas: {

          # ==========================
          # 🔹 Infra / Error Handling
          # ==========================

          RequestDetails: {
            type: :object,
            properties: {
              occurredAt: {
                type: :string,
                format: :'date-time',
                example: '2025-01-01T12:00:00Z'
              },
              requestId: {
                type: :string,
                example: 'c8f8c9c2-9dcb-4e9b-b5c2-123456789abc'
              },
              path: {
                type: :string,
                example: '/api/v1/products/999'
              }
            },
            required: %w[occurredAt requestId path]
          },

          ErrorDetails: {
            type: :object,
            properties: {
              message: {
                type: :string,
                example: "Name can't be blank"
              },
              errorType: {
                type: :string,
                example: 'VALIDATION_ERROR'
              }
            },
            required: %w[message errorType]
          },

          ErrorResponse: {
            type: :object,
            properties: {
              message: {
                oneOf: [
                  { type: :string },
                  {
                    type: :array,
                    items: { type: :string }
                  }
                ],
                example: 'Record not found'
              },
              internalErrorCode: {
                type: :string,
                nullable: true,
                example: 'ERR-001'
              },
              errorType: {
                type: :string,
                nullable: true,
                example: 'NOT_FOUND'
              },
              requestDetails: {
                '$ref' => '#/components/schemas/RequestDetails'
              },
              additionalErrors: {
                type: :array,
                items: {
                  '$ref' => '#/components/schemas/ErrorDetails'
                }
              }
            },
            required: %w[message requestDetails]
          },

          Product: {
            type: :object,
            properties: {
              id: {
                type: :integer,
                example: 1
              },
              name: {
                type: :string,
                example: 'Keyboard'
              },
              description: {
                type: :string,
                nullable: true,
                example: 'Mechanical keyboard'
              },
              price: {
                type: :string,
                format: :float,
                example: "199.90"
              },
              created_at: {
                type: :string,
                format: :'date-time'
              },
              updated_at: {
                type: :string,
                format: :'date-time'
              }
            },
            required: %w[id name price]
          },

          Customer: {
            type: :object,
            properties: {
              id: {
                type: :integer,
                example: 1
              },
              name: {
                type: :string,
                example: 'John Doe'
              },
              email: {
                type: :string,
                format: :email,
                example: 'john@example.com'
              },
              phone: {
                type: :string,
                nullable: true,
                example: '999999999'
              },
              created_at: {
                type: :string,
                format: :'date-time'
              },
              updated_at: {
                type: :string,
                format: :'date-time'
              }
            },
            required: %w[id name email]
          },

          Order: {
            type: :object,
            properties: {
              id: {
                type: :integer,
                example: 1
              },
              customer_id: {
                type: :integer,
                example: 1
              },
              status: {
                type: :string,
                example: 'new'
              },
              total_amount: {
                type: :string,
                format: :float,
                example: "250.00"
              },
              created_at: {
                type: :string,
                format: :'date-time'
              },
              updated_at: {
                type: :string,
                format: :'date-time'
              }
            },
            required: %w[id customer_id status total_amount]
          },

          OrderProduct: {
            type: :object,
            properties: {
              id: {
                type: :integer,
                example: 1
              },
              order_id: {
                type: :integer,
                example: 1
              },
              product_id: {
                type: :integer,
                example: 1
              },
              quantity: {
                type: :integer,
                example: 2
              },
              price: {
                type: :string,
                format: :float,
                example: "100.00"
              },
              created_at: {
                type: :string,
                format: :'date-time'
              },
              updated_at: {
                type: :string,
                format: :'date-time'
              }
            },
            required: %w[id order_id product_id quantity]
          }
        }
      }
    }
  }

  config.openapi_format = :yaml
end
