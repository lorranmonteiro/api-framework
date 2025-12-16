# API REST – Sistema de Pedidos

Este projeto consiste no desenvolvimento de uma **API RESTful** criada como **Trabalho de Conclusão de Curso (TCC)**, com foco na análise e aplicação de **padrões de projeto de software**, boas práticas de arquitetura e documentação de APIs.

A API foi projetada para gerenciar entidades relacionadas a um sistema de pedidos, permitindo operações de criação, consulta, atualização e remoção de recursos, seguindo princípios amplamente adotados na engenharia de software.

---

## Motivação e Objetivo

A motivação deste projeto é aplicar, de forma prática, conceitos estudados ao longo do curso, especialmente relacionados à **engenharia de software**, **arquitetura de sistemas** e **padrões de projeto**.

O objetivo principal do TCC é demonstrar como o uso de boas práticas — como separação de responsabilidades, padronização de respostas, testes automatizados e documentação baseada em contrato — contribui para a construção de uma API mais **manutenível, escalável e confiável**.

---

## Escopo da API

A API disponibiliza endpoints para gerenciamento dos seguintes recursos:

- Customers (Clientes)
- Products (Produtos)
- Orders (Pedidos)
- OrderProducts (Itens de Pedido)

Também são oferecidos endpoints específicos para:
- Listar pedidos de um cliente
- Listar produtos associados a um pedido

A API **não possui autenticação** e é aberta para uso, tendo como objetivo principal fins educacionais e acadêmicos.

---

## Tecnologias Utilizadas

- Ruby 3.3.10
- Ruby on Rails 8.1.1 (API Mode)
- PostgreSQL
- RSpec
- FactoryBot
- Rswag
- OpenAPI (Swagger)
- Rack CORS

---

## Documentação da API

A documentação da API é gerada automaticamente a partir dos testes utilizando o padrão **OpenAPI**, podendo ser acessada em:
/api-docs

---

## Testes Automatizados

O projeto conta com testes automatizados para:

- Models (validações, associações e callbacks)
- Endpoints da API
- Geração automática da documentação OpenAPI



## Considerações Acadêmicas

Este projeto foi desenvolvido com foco acadêmico, priorizando organização do código, clareza arquitetural, padronização de contratos e documentação automatizada.

Pode ser utilizado como base de estudo ou referência para projetos que envolvam desenvolvimento de APIs REST.

## Licença

Projeto disponibilizado para fins educacionais e acadêmicos.
