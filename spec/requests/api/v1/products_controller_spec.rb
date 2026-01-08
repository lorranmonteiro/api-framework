require "rails_helper"

RSpec.describe "Api::V1::ProductsController", type: :request do
  let!(:product1) { create(:product, name: "Product A", price: 10.50) }
  let!(:product2) { create(:product, price: 20.00) }

  let(:base_url) { "/api/v1/products" }

  describe "GET /api/v1/products" do
    it "returns all products" do
      get base_url

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json.size).to eq(2)
      expect(json.first["name"]).to eq("Product A")
    end
  end

  describe "GET /api/v1/products/:id" do
    context "when the product exists" do
      it "returns the product" do
        get "#{base_url}/#{product1.id}"

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json["name"]).to eq("Product A")
      end
    end

    context "when the product does not exist" do
      it "returns a NOT_FOUND error" do
        get "#{base_url}/99999"

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)

        expect(json["errors"]).to be_an(Array)
        expect(json["errors"].size).to eq(1)

        error = json["errors"].first
        expect(error["message"]).to eq(Constants::RECORD_NOT_FOUND_MESSAGE)
        expect(error["errorCode"]).to eq(ErrorCodes::NOT_FOUND)

        expect(json["metadata"]).to be_present
        expect(json["metadata"]["path"]).to eq("/api/v1/products/99999")
        expect(json["metadata"]["statusCode"]).to eq(404)
      end
    end
  end

  describe "POST /api/v1/products" do
    let(:valid_params) do
      {
        product: { name: "New Product", description: "Some text", price: 15.99 }
      }
    end

    let(:invalid_params) do
      {
        product: { name: "", price: -10 }
      }
    end

    context "with valid params" do
      it "creates a product" do
        post base_url, params: valid_params

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)

        expect(json["name"]).to eq("New Product")
        expect(json["price"]).to eq("15.99")
      end
    end

    context "with invalid params" do
      it "returns validation errors" do
        post base_url, params: invalid_params

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)

        expect(json["errors"]).to be_an(Array)
        expect(json["errors"].size).to be >= 1

        messages = json["errors"].map { |e| e["message"] }

        expect(messages).to include(
          "Name can't be blank",
          "Price must be greater than 0"
        )

        json["errors"].each do |error|
          expect(error["errorCode"]).to eq(ErrorCodes::FIELD_VALIDATION)
        end

        expect(json["metadata"]).to be_present
        expect(json["metadata"]["statusCode"]).to eq(422)
      end
    end
  end

  describe "PATCH /api/v1/products/:id" do
    context "with valid attributes" do
      it "updates the product" do
        patch "#{base_url}/#{product1.id}", params: {
          product: { name: "Updated Product Name" }
        }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json["name"]).to eq("Updated Product Name")
      end
    end

    context "with invalid attributes" do
      it "returns validation error" do
        patch "#{base_url}/#{product1.id}", params: {
          product: { price: -50 }
        }

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)

        expect(json["errors"]).to be_an(Array)
        expect(json["errors"].first["message"])
          .to eq("Price must be greater than 0")

        expect(json["errors"].first["errorCode"])
          .to eq(ErrorCodes::FIELD_VALIDATION)

        expect(json["metadata"]).to be_present
        expect(json["metadata"]["statusCode"]).to eq(422)
      end
    end
  end

  describe "DELETE /api/v1/products/:id" do
    it "deletes the product" do
      delete "#{base_url}/#{product1.id}"

      expect(response).to have_http_status(:no_content)
      expect(Product.find_by(id: product1.id)).to be_nil
    end

    it "returns NOT_FOUND when product does not exist" do
      delete "#{base_url}/99999"

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)

      expect(json["errors"].first["message"]).to eq(Constants::RECORD_NOT_FOUND_MESSAGE)
      expect(json["errors"].first["errorCode"]).to eq(ErrorCodes::NOT_FOUND)
      expect(json["metadata"]["statusCode"]).to eq(404)
    end
  end
end
