require "swagger_helper"

RSpec.describe "Orders API", type: :request, swagger_doc: "v1/swagger.yaml" do
  let!(:customer) { create(:customer) }
  let!(:order1)   { create(:order, customer: customer, status: "New", total_amount: 100) }
  let!(:order2)   { create(:order, customer: customer, status: "In progress", total_amount: 200) }

  path "/api/v1/orders" do
    get "List orders" do
      tags "Orders"
      produces "application/json"

      response "200", "orders found" do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id:           { type: :integer },
                   customer_id:  { type: :integer },
                   status:       { type: :string },
                   total_amount: { type: :number, format: :float }
                 }
               }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json.size).to eq(2)
          expect(json.first["total_amount"].to_f).to eq(100.0)
        end
      end
    end

    post "Create order" do
      tags "Orders"
      consumes "application/json"
      produces "application/json"

      parameter name: :order, in: :body, schema: {
        type: :object,
        properties: {
          customer_id: { type: :integer },
          status:      { type: :string, enum: ["New", "In progress", "Done"] },
          total_amount:{ type: :number, format: :float }
        },
        required: %w[customer_id status total_amount]
      }

      response "201", "order created" do
        schema type: :object,
               properties: {
                 id:           { type: :integer },
                 customer_id:  { type: :integer },
                 status:       { type: :string },
                 total_amount: { type: :number, format: :float }
               }

        let(:order) do
          {
            customer_id: customer.id,
            status: "New",
            total_amount: 50
          }
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["status"]).to eq("new_order")
          expect(json["total_amount"].to_f).to eq(50.0)
        end
      end

      response "422", "invalid order" do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:order) do
          {
            customer_id: nil,
            status: "",
            total_amount: -10
          }
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["message"]).to be_an(Array)
          expect(json["message"]).to include("Customer must exist")
          expect(json["message"]).to include("Status can't be blank")
          expect(json["message"]).to include("Total amount must be greater than or equal to 0.0")
        end
      end
    end
  end

  path "/api/v1/orders/{id}" do
    parameter name: :id, in: :path, type: :integer

    get "Show order" do
      tags "Orders"
      produces "application/json"

      response "200", "order found" do
        schema type: :object,
               properties: {
                 id:           { type: :integer },
                 customer_id:  { type: :integer },
                 status:       { type: :string },
                 total_amount: { type: :number, format: :float }
               }

        let(:id) { order1.id }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["total_amount"].to_f).to eq(100.0)
        end
      end

      response "404", "order not found" do
        schema '$ref' => '#/components/schemas/ErrorResponse'
        let(:id) { 99999 }
        run_test!
      end
    end

    patch "Update order" do
      tags "Orders"
      consumes "application/json"
      produces "application/json"

      parameter name: :order, in: :body, schema: {
        type: :object,
        properties: {
          status:       { type: :string, enum: ["New", "In progress", "Done"] },
          total_amount: { type: :number, format: :float }
        }
      }

      response "200", "order updated" do
        schema type: :object,
               properties: {
                 id:           { type: :integer },
                 customer_id:  { type: :integer },
                 status:       { type: :string },
                 total_amount: { type: :number, format: :float }
               }

        let(:id) { order1.id }
        let(:order) { { status: "Done" } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["status"]).to eq("done")
        end
      end

      response "422", "invalid update" do
        schema '$ref' => '#/components/schemas/ErrorResponse'
        let(:id) { order1.id }
        let(:order) { { total_amount: -5 } }
        run_test!
      end
    end

    delete "Delete order" do
      tags "Orders"

      response "204", "order deleted" do
        let(:id) { order1.id }
        run_test!
      end

      response "404", "order not found" do
        schema '$ref' => '#/components/schemas/ErrorResponse'
        let(:id) { 99999 }
        run_test!
      end
    end
  end

  path "/api/v1/customer/{customer_id}/orders" do
    parameter name: :customer_id, in: :path, type: :integer

    get "List orders by customer" do
      tags "Orders"
      produces "application/json"

      response "200", "orders found" do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id:           { type: :integer },
                   customer_id:  { type: :integer },
                   status:       { type: :string },
                   total_amount: { type: :number, format: :float }
                 }
               }

        let(:customer_id) { customer.id }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json.size).to eq(2)
          expect(json.first["customer_id"]).to eq(customer.id)
        end
      end

      response "404", "customer not found" do
        schema '$ref' => '#/components/schemas/ErrorResponse'
        let(:customer_id) { 99999 }
        run_test!
      end
    end
  end
end
