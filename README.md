# API REST – Sistema de Pedidos

**Análise e Proposta de Padronização de Respostas de Erro em APIs REST**

Este projeto apresenta o desenvolvimento de uma **API RESTful**, criada como **Trabalho de Conclusão de Curso (TCC)**, cujo objetivo central é a **análise crítica dos padrões de resposta de erro propostos pela literatura e adotados pelo mercado**, culminando na **proposição de um novo padrão unificado**.

O domínio de **sistema de pedidos** (clientes, produtos e pedidos) é utilizado apenas como **ambiente experimental**, permitindo avaliar o comportamento do padrão proposto em cenários reais, sem que o foco esteja na complexidade do negócio.

---

## Motivação

A literatura clássica sobre APIs REST recomenda o uso do [RFC 7807 – Problem Details for HTTP APIs](https://www.rfc-editor.org/rfc/rfc7807) como padrão para representação de erros. Embora amplamente citado, esse padrão apresenta limitações práticas observadas na adoção real, tais como:

* Dificuldade em representar múltiplos erros simultaneamente
* Acoplamento conceitual entre semântica do erro e status HTTP
* Fragmentação da informação de erro em campos distintos, exigindo lógica adicional nos clientes

Em contraste, **APIs amplamente utilizadas no mercado** (Google, Stripe, GitHub, AWS, Shopify, entre outras) adotam estruturas próprias, geralmente mais simples, previsíveis e orientadas ao consumo.

Diante desse cenário, este trabalho propõe um **novo padrão de resposta de erro**, que **unifica conceitos da literatura com práticas consolidadas do mercado**, priorizando clareza, consistência e extensibilidade.

---

## Documentação e Escopo da API

A documentação completa da API — incluindo exemplos do padrão de erro proposto — está disponível no **Swagger UI**:

🔗 [https://api-framework.onrender.com](https://api-framework.onrender.com)

A API expõe endpoints REST para os seguintes recursos:

* **Customers** (Clientes)
* **Products** (Produtos)
* **Orders** (Pedidos)
* **OrderProducts** (Itens de Pedido)

As operações CRUD servem como base para avaliar diferentes categorias de erro, como:

* Erros de validação
* Recursos não encontrados
* Erros internos inesperados

> **Observação:**
> A API não possui autenticação ou autorização. Essa decisão é intencional e visa manter o foco exclusivo em contratos de erro, arquitetura e testes, conforme o escopo acadêmico do trabalho.

---

## Padrão Proposto de Resposta de Erro

### Estrutura do RFC 7807 (referência)

```json
{
  "type": "https://example.com/probs/out-of-credit",
  "title": "You do not have enough credit.",
  "status": 403,
  "detail": "Your current balance is 30, but that costs 50.",
  "instance": "/account/12345/msgs/abc"
}
```

### Estrutura proposta neste projeto

```json
{
  "errors": [
    {
      "errorType": "FIELD_VALIDATION",
      "errorCode": "ERROR-002",
      "message": "Name cannot contain special characters."
    },
    {
      "errorType": "FIELD_VALIDATION",
      "errorCode": "ERROR-003",
      "message": "Email cannot be empty."
    }
  ],
  "metadata": {
    "requestId": "123e4567-e89b-12d3-a456-426614174000",
    "timestamp": "2024-06-15T12:34:56Z",
    "path": "/users/11"
  }
}
```

### Características do padrão proposto

* Lista explícita de erros (`errors[]`), sem hierarquia artificial
* Códigos de erro **semânticos e estáveis** (`errorType`)
* Códigos de erro **específicos do domínio** (`errorInternalCode`)
* Metadados da requisição agrupados em `metadata` para facilitar debugging
* Independência total entre estrutura do erro e status HTTP
* Suporte nativo a múltiplos erros em uma única resposta

Esse modelo busca resolver limitações do RFC 7807 **sem violar os princípios REST**, ao mesmo tempo em que se aproxima das práticas observadas em APIs amplamente utilizadas no mercado.

---

## Feedback e Contribuições

Um formulário foi disponibilizado para coleta de feedbacks e sugestões:

🔗 [Avaliação de Experiência e Padronização de API REST](https://forms.gle/8FWQB2RUCCF45aoM6)

Sua participação é fundamental para o refinamento e validação desta proposta acadêmica.

---

## Considerações Acadêmicas

Este projeto possui finalidade **estritamente acadêmica**, servindo como:

* Base experimental para análise de padrões de erro em APIs REST
* Proposta formal de um novo contrato de resposta de erro
* Referência técnica para estudos sobre arquitetura e contratos de API

O foco está na **qualidade arquitetural**, **clareza de contrato** e **padronização de erros**, e não na complexidade do domínio de negócio.

---

## Licença

Projeto disponibilizado exclusivamente para fins **educacionais e acadêmicos**.
