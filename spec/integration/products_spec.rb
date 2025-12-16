require "swagger_helper"

RSpec.describe "Products API", type: :request, swagger_doc: "v1/swagger.yaml" do
  let!(:product1) { create(:product, name: "Product A", price: 10.50) }
  let!(:product2) { create(:product, price: 20.00) }

  path "/api/v1/products" do
    get "List products" do
      tags "Products"
      produces "application/json"

      response "200", "products found" do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id:          { type: :integer },
                   name:        { type: :string },
                   description: { type: :string, nullable: true },
                   price:       { type: :number, format: :float },
                   stock:       { type: :integer, nullable: true }
                 }
               }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json.size).to eq(2)
          expect(json.first["name"]).to eq("Product A")
        end
      end
    end

    post "Create product" do
      tags "Products"
      consumes "application/json"
      produces "application/json"

      parameter name: :product, in: :body, schema: {
        type: :object,
        properties: {
          name:        { type: :string },
          description: { type: :string },
          price:       { type: :number, format: :float },
          stock:       { type: :integer }
        },
        required: %w[name price]
      }

      response "201", "product created" do
        schema type: :object,
               properties: {
                 id:          { type: :integer },
                 name:        { type: :string },
                 description: { type: :string, nullable: true },
                 price:       { type: :number, format: :float },
                 stock:       { type: :integer, nullable: true }
               }

        let(:product) do
          {
            name: "New Product",
            description: "Some text",
            price: 15.99
          }
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["name"]).to eq("New Product")
          expect(json["price"]).to eq("15.99")
        end
      end

      response "422", "invalid product" do
        schema '$ref' => '#/components/schemas/ErrorResponse'

        let(:product) do
          {
            name: "",
            price: -10
          }
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["message"]).to be_an(Array)
          expect(json["message"]).to include("Name can't be blank")
          expect(json["message"]).to include("Price must be greater than or equal to 0")
        end
      end
    end
  end

  path "/api/v1/products/{id}" do
    parameter name: :id, in: :path, type: :integer

    get "Show product" do
      tags "Products"
      produces "application/json"

      response "200", "product found" do
        schema type: :object,
               properties: {
                 id:          { type: :integer },
                 name:        { type: :string },
                 description: { type: :string, nullable: true },
                 price:       { type: :number, format: :float },
                 stock:       { type: :integer, nullable: true }
               }

        let(:id) { product1.id }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["name"]).to eq("Product A")
        end
      end

      response "404", "product not found" do
        schema '$ref' => '#/components/schemas/ErrorResponse'
        let(:id) { 99999 }
        run_test!
      end
    end

    patch "Update product" do
      tags "Products"
      consumes "application/json"
      produces "application/json"

      parameter name: :product, in: :body, schema: {
        type: :object,
        properties: {
          name:  { type: :string },
          price: { type: :number, format: :float }
        }
      }

      response "200", "product updated" do
        schema type: :object,
               properties: {
                 id:          { type: :integer },
                 name:        { type: :string },
                 description: { type: :string, nullable: true },
                 price:       { type: :number, format: :float },
                 stock:       { type: :integer, nullable: true }
               }

        let(:id) { product1.id }
        let(:product) { { name: "Updated Product Name" } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["name"]).to eq("Updated Product Name")
        end
      end

      response "422", "invalid update" do
        schema '$ref' => '#/components/schemas/ErrorResponse'
        let(:id) { product1.id }
        let(:product) { { price: -50 } }
        run_test!
      end
    end

    delete "Delete product" do
      tags "Products"

      response "204", "product deleted" do
        let(:id) { product1.id }
        run_test!
      end

      response "404", "product not found" do
        schema '$ref' => '#/components/schemas/ErrorResponse'
        let(:id) { 99999 }
        run_test!
      end
    end
  end
end
