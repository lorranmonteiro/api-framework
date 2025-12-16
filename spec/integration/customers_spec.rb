require "swagger_helper"

RSpec.describe "Customers API", type: :request, swagger_doc: "v1/swagger.yaml" do
  let!(:customer1) { create(:customer, name: "John Doe") }
  let!(:customer2) { create(:customer) }

  path "/api/v1/customers" do
    get "List customers" do
      tags "Customers"
      produces "application/json"

      response "200", "customers found" do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id:    { type: :integer },
                   name:  { type: :string },
                   email: { type: :string },
                   phone: { type: :string }
                 }
               }

        run_test!
      end
    end

    post "Create customer" do
      tags "Customers"
      consumes "application/json"
      produces "application/json"

      parameter name: :customer, in: :body, schema: {
        type: :object,
        properties: {
          name:  { type: :string },
          email: { type: :string },
          phone: { type: :string }
        },
        required: %w[name email]
      }

      response "201", "customer created" do
        schema type: :object,
               properties: {
                 id:    { type: :integer },
                 name:  { type: :string },
                 email: { type: :string },
                 phone: { type: :string }
               }

        let(:customer) do
          {
            name: "Mike",
            email: "mike@example.com",
            phone: "999999"
          }
        end

        run_test!
      end

      response "422", "invalid request" do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:customer) do
          {
            name: "",
            email: "",
            phone: "999999"
          }
        end

        run_test!
      end
    end
  end

  path "/api/v1/customers/{id}" do
    parameter name: :id, in: :path, type: :integer

    get "Show customer" do
      tags "Customers"
      produces "application/json"

      response "200", "customer found" do
        schema type: :object,
               properties: {
                 id:    { type: :integer },
                 name:  { type: :string },
                 email: { type: :string },
                 phone: { type: :string }
               }

        let(:id) { customer1.id }
        run_test!
      end

      response "404", "customer not found" do
        schema '$ref' => '#/components/schemas/ErrorResponse'
        let(:id) { 99999 }
        run_test!
      end
    end

    patch "Update customer" do
      tags "Customers"
      consumes "application/json"
      produces "application/json"

      parameter name: :customer, in: :body, schema: {
        type: :object,
        properties: {
          name:  { type: :string },
          email: { type: :string }
        }
      }

      response "200", "customer updated" do
        schema type: :object,
               properties: {
                 id:    { type: :integer },
                 name:  { type: :string },
                 email: { type: :string },
                 phone: { type: :string }
               }

        let(:id) { customer1.id }
        let(:customer) { { name: "Updated Name" } }

        run_test!
      end

      response "422", "invalid update" do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:id) { customer1.id }
        let(:customer) { { email: "" } }

        run_test!
      end
    end

    delete "Delete customer" do
      tags "Customers"

      response "204", "customer deleted" do
        let(:id) { customer1.id }
        run_test!
      end

      response "404", "customer not found" do
        schema '$ref' => '#/components/schemas/ErrorResponse'
        let(:id) { 99999 }
        run_test!
      end
    end
  end
end
