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
        description: 'Esta é a documentação da API REST para o Trabalho de Conclusão de Curso (TCC), voltado para análise de proposta de padrão de projeto de software. A API oferece endpoints para gerenciar recursos relacionados ao sistema desenvolvido, permitindo operações CRUD e outras funcionalidades essenciais, seguindo as melhores práticas de desenvolvimento de software.',
      },
      paths: {},
      components: {
        schemas: {

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
          }
        }
      }
    }
  }

  config.openapi_format = :yaml
end
