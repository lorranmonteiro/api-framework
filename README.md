# API REST – Sistema de Pedidos

Este projeto consiste no desenvolvimento de uma **API RESTful**, criada como **Trabalho de Conclusão de Curso (TCC)**, com foco na aplicação prática de **conceitos de engenharia de software**, **boas práticas arquiteturais**, **padrões de projeto** e **documentação orientada a contrato**, focado na proposta de um padrão de respostas de erro consistente e dinâmico.

A API foi projetada para gerenciar entidades de um sistema de pedidos, permitindo operações de **criação, consulta, atualização e remoção (CRUD)** de recursos, seguindo princípios amplamente adotados no desenvolvimento de APIs modernas.

O projeto está **publicamente disponível** e em execução contínua, servindo como **material de estudo, referência técnica e base para análise acadêmica**, até o TCC ser defendido.

---

## Escopo da API

A API disponibiliza endpoints para o gerenciamento dos seguintes recursos:

* **Customers** (Clientes)
* **Products** (Produtos)
* **Orders** (Pedidos)
* **OrderProducts** (Itens de Pedido)

Além das operações CRUD padrão, a API oferece endpoints específicos para:

* Listar pedidos associados a um cliente
* Listar produtos associados a um pedido

**Observação**
A API **não possui autenticação ou autorização**. Essa decisão é intencional e visa manter o foco do projeto em **arquitetura, padronização, testes e documentação**, com finalidade **estritamente educacional e acadêmica**.

---

## Decisões Arquiteturais

Esta seção descreve as principais decisões arquiteturais adotadas no desenvolvimento da API e suas motivações técnicas e acadêmicas.

### Arquitetura RESTful e Rails em Modo API

A aplicação foi desenvolvida utilizando **Ruby on Rails em modo API**, removendo camadas desnecessárias como views e helpers voltados para aplicações monolíticas tradicionais. Essa abordagem resulta em uma arquitetura mais **enxuta**, focada em:

* Exposição de endpoints REST
* Serialização de dados
* Tratamento de erros
* Testabilidade

A API segue os princípios REST, utilizando:

* Verbos HTTP adequados (GET, POST, PATCH, DELETE)
* Códigos de status coerentes com a especificação HTTP
* URLs orientadas a recursos

---

### Tratamento e Padronização de Erros

Uma das principais decisões arquiteturais do projeto foi a implementação de um **framework centralizado de tratamento de erros**, responsável por capturar e padronizar todas as falhas da aplicação, incluindo:

* Recursos não encontrados (`404`)
* Erros de validação (`422`)
* Erros internos inesperados (`500`)

Todas as respostas de erro seguem um contrato padronizado, contendo, entre outros dados:

* `message`: mensagem principal do erro
* `errorType`: classificação semântica do erro
* `internalErrorCode`: código interno padronizado
* `requestDetails`: metadados da requisição
* `additionalErrors`: lista opcional de erros complementares

Essa abordagem garante **consistência**, **previsibilidade** e **facilidade de consumo** por aplicações clientes.

---

### Testes como Fonte de Verdade

O projeto adota a filosofia de **testes como documentação viva**, onde:

* Os testes validam o comportamento esperado da API
* Os mesmos testes geram a documentação OpenAPI
* Casos de sucesso e erro são explicitamente cobertos

Essa estratégia reduz divergências entre código, documentação e comportamento real da aplicação.

---

### Documentação Orientada a Contrato (OpenAPI)

A documentação da API é gerada automaticamente a partir dos testes utilizando o padrão **OpenAPI (Swagger)**.

A interface do Swagger inclui:

* Playground para execução de requisições
* Exemplos de payloads
* Descrição detalhada dos endpoints
* Contratos de request e response
* Padronização de respostas de erro

---

### Ausência Intencional de Autenticação

A ausência de autenticação foi uma decisão consciente, com o objetivo de:

* Reduzir complexidade fora do escopo do TCC
* Manter o foco em arquitetura, padrões e contratos
* Facilitar testes e uso por terceiros

Em um cenário de produção real, mecanismos como JWT ou OAuth poderiam ser integrados sem impacto significativo na arquitetura atual.

---

## Tecnologias Utilizadas

* **Ruby** 3.3.10
* **Ruby on Rails** 8.1.1 (API Mode)
* **PostgreSQL**
* **RSpec** (testes automatizados)
* **FactoryBot**
* **Rswag**
* **OpenAPI (Swagger)**
* **Rack CORS**

---

## Ambiente e Disponibilidade

A API está publicada em ambiente público e permanece disponível continuamente para testes e avaliação.

Dados iniciais (clientes e produtos) são carregados via **seed** em produção, permitindo que usuários explorem os endpoints sem necessidade de configuração prévia.

---

## Considerações Acadêmicas

Este projeto foi desenvolvido com foco acadêmico, priorizando:

* Organização e legibilidade do código
* Clareza arquitetural
* Boas práticas de desenvolvimento
* Padronização de contratos
* Documentação automatizada
* Testes como fonte de verdade do comportamento da API

Pode ser utilizado como **base de estudo**, **referência técnica** ou **apoio didático** para disciplinas relacionadas ao desenvolvimento de APIs REST e engenharia de software.

---

## Licença

Projeto disponibilizado exclusivamente para fins **educacionais e acadêmicos**.
