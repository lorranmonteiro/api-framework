# API REST – Sistema de Pedidos

**Análise e Proposta de Padronização de Respostas de Erro em APIs REST**

Este projeto consiste no desenvolvimento de uma **API RESTful**, criada como **Trabalho de Conclusão de Curso (TCC)**, cujo **objetivo central** é a **análise crítica dos padrões de resposta de erro propostos pela literatura e adotados pelo mercado**, culminando na **proposição de um novo padrão unificado**.

Embora a API implemente um domínio simples de **sistema de pedidos**, esse domínio atua apenas como **meio experimental**, permitindo avaliar, validar e demonstrar o comportamento do padrão de erro proposto em cenários reais de uso.

---

## Motivação

A literatura clássica sobre APIs REST recomenda o uso do **RFC 7807 – Problem Details for HTTP APIs** como padrão para representação de erros. Apesar de sua adoção formal, o RFC apresenta limitações práticas amplamente discutidas no mercado, tais como:

* Estrutura excessivamente genérica e pouco orientada a validações complexas
* Dificuldade em representar **múltiplos erros simultâneos** de forma clara
* Acoplamento conceitual entre semântica do erro e status HTTP
* Baixa padronização de extensões entre diferentes APIs

Em paralelo, empresas e plataformas amplamente utilizadas (Google, Stripe, GitHub, AWS, Shopify, entre outras) adotam **estruturas próprias**, frequentemente divergentes do RFC, mas mais práticas, previsíveis e orientadas ao consumo por clientes frontend.

Diante desse cenário, este trabalho propõe um **novo padrão de resposta de erro**, que **unifica conceitos da literatura com práticas consolidadas do mercado**, buscando maior clareza, consistência e extensibilidade.

---

## Escopo da API

A API fornece endpoints REST para os seguintes recursos:

* **Customers** (Clientes)
* **Products** (Produtos)
* **Orders** (Pedidos)
* **OrderProducts** (Itens de Pedido)

As operações CRUD são utilizadas como base para avaliar diferentes categorias de erro, como:

* Erros de validação
* Recursos não encontrados
* Erros internos inesperados

> **Observação:**
> A API não possui autenticação ou autorização. Essa decisão é intencional e visa manter o foco exclusivo na **arquitetura de erros, contratos e testes**, alinhado ao escopo acadêmico do trabalho.

---

## Padrão Proposto de Resposta de Erro

Como resultado da análise da literatura e das soluções adotadas pelo mercado, o projeto propõe um **formato unificado de resposta de erro**, desacoplado da lógica de exceções internas e orientado ao consumo por clientes.

### Estrutura do Erro

```json
{
  "errors": [
    {
      "errorCode": "FIELD_VALIDATION",
      "message": "Name cannot contain special characters."
    },
    {
      "errorCode": "FIELD_VALIDATION",
      "message": "Email cannot be empty."
    }
  ],
  "metadata": {
    "requestId": "123e4567-e89b-12d3-a456-426614174000",
    "occurredAt": "2024-06-15T12:34:56Z",
    "path": "/users/11",
    "statusCode": 422
  }
}
```

### Principais Características

* Lista explícita de erros (`errors[]`), sem hierarquia artificial
* Códigos de erro semânticos e estáveis (`errorCode`)
* Metadados de requisição agrupados em `metadata`
* Total independência entre estrutura de erro e status HTTP
* Suporte nativo a múltiplos erros em uma única resposta

Esse modelo busca resolver limitações do RFC 7807 sem romper com os princípios REST.

---

## Testes e Documentação

O projeto adota **testes automatizados como fonte de verdade do contrato**, onde:

* Testes validam o comportamento real da API
* Os mesmos testes geram a documentação OpenAPI (Swagger)
* Casos de sucesso e erro são explicitamente documentados

Essa abordagem garante **consistência entre código, testes e documentação**, evitando divergências comuns em APIs documentadas manualmente.

---

## Tecnologias Utilizadas

* **Ruby** 3.3
* **Ruby on Rails** (API Mode)
* **PostgreSQL**
* **RSpec**
* **FactoryBot**
* **Rswag / OpenAPI (Swagger)**

---

## Considerações Acadêmicas

Este projeto tem finalidade **estritamente acadêmica**, servindo como:

* Base experimental para análise de padrões de erro
* Proposta formal de um novo contrato de resposta de erro
* Referência técnica para estudos sobre APIs REST

O foco não está no domínio de negócio, mas na **qualidade arquitetural**, **padronização** e **clareza de contrato**.

---

## Licença

Projeto disponibilizado exclusivamente para fins **educacionais e acadêmicos**.
