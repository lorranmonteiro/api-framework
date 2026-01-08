require 'rails_helper'

RSpec.describe "Api::V1::CustomersController", type: :request do
  let!(:customer1) { create(:customer, name: "John Doe") }
  let!(:customer2) { create(:customer) }

  let(:base_url) { "/api/v1/customers" }

  describe "GET /api/v1/customers" do
    it "returns all customers" do
      get base_url

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json.size).to eq(2)
      expect(json.first["name"]).to eq("John Doe")
    end
  end

  describe "GET /api/v1/customers/:id" do
    context "when the customer exists" do
      it "returns the customer" do
        get "#{base_url}/#{customer1.id}"

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json["name"]).to eq("John Doe")
      end
    end

    context "when the customer does not exist" do
      it "returns a NOT_FOUND error" do
        get "#{base_url}/99999"

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)

        expect(json["errors"]).to be_an(Array)
        expect(json["errors"].size).to eq(1)

        error = json["errors"].first
        expect(error["errorCode"]).to eq(ErrorCodes::NOT_FOUND)
        expect(error["message"]).to eq(Constants::RECORD_NOT_FOUND_MESSAGE)

        expect(json["metadata"]).to be_present
        expect(json["metadata"]["path"]).to eq("/api/v1/customers/99999")
        expect(json["metadata"]["statusCode"]).to eq(404)
      end
    end
  end

  describe "POST /api/v1/customers" do
    let(:valid_params) do
      { customer: { name: "Mike", email: "mike@example.com", phone: "999999" } }
    end

    let(:invalid_params) do
      { customer: { name: "", email: "", phone: "999999" } }
    end

    context "with valid params" do
      it "creates a customer" do
        post base_url, params: valid_params

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)

        expect(json["name"]).to eq("Mike")
        expect(json["email"]).to eq("mike@example.com")
      end
    end

    context "with invalid params" do
      it "returns a structured validation error list" do
        post base_url, params: invalid_params

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)

        expect(json["errors"]).to be_an(Array)
        expect(json["errors"].size).to eq(2)

        expect(json["errors"]).to include(
          hash_including(
            "errorCode" => ErrorCodes::FIELD_VALIDATION,
            "message" => "Name can't be blank"
          ),
          hash_including(
            "errorCode" => ErrorCodes::FIELD_VALIDATION,
            "message" => "Email can't be blank"
          )
        )

        expect(json["metadata"]).to be_present
        expect(json["metadata"]["statusCode"]).to eq(422)
        expect(json["metadata"]["path"]).to eq("/api/v1/customers")
      end
    end
  end

  describe "PATCH /api/v1/customers/:id" do
    context "with valid attributes" do
      it "updates the customer" do
        patch "#{base_url}/#{customer1.id}", params: {
          customer: { name: "Updated Name" }
        }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json["name"]).to eq("Updated Name")
      end
    end

    context "with invalid attributes" do
      it "returns a structured validation error" do
        patch "#{base_url}/#{customer1.id}", params: {
          customer: { email: "" }
        }

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)

        expect(json["errors"]).to be_an(Array)
        expect(json["errors"].size).to eq(1)

        error = json["errors"].first
        expect(error["errorCode"]).to eq(ErrorCodes::FIELD_VALIDATION)
        expect(error["message"]).to eq("Email can't be blank")

        expect(json["metadata"]).to be_present
        expect(json["metadata"]["statusCode"]).to eq(422)
      end
    end
  end

  describe "DELETE /api/v1/customers/:id" do
    it "deletes the customer" do
      delete "#{base_url}/#{customer1.id}"

      expect(response).to have_http_status(:no_content)
      expect(Customer.find_by(id: customer1.id)).to be_nil
    end

    it "returns NOT_FOUND when customer doesn't exist" do
      delete "#{base_url}/99999"

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)

      expect(json["errors"]).to be_an(Array)
      expect(json["errors"].size).to eq(1)

      error = json["errors"].first
      expect(error["errorCode"]).to eq(ErrorCodes::NOT_FOUND)
      expect(error["message"]).to eq(Constants::RECORD_NOT_FOUND_MESSAGE)

      expect(json["metadata"]["statusCode"]).to eq(404)
    end
  end

  describe "Internal Server Error (500)" do
    it "returns a standardized error response when an unexpected error occurs" do
      allow(Product).to receive(:all).and_raise(StandardError.new("Boom"))

      get "/api/v1/products"

      expect(response).to have_http_status(:internal_server_error)
      json = JSON.parse(response.body)

      expect(json["errors"]).to be_an(Array)
      expect(json["errors"].size).to eq(1)

      error = json["errors"].first
      expect(error["errorCode"]).to eq(ErrorCodes::INTERNAL_SERVER_ERROR)
      expect(error["message"]).to eq(Constants::INTERNAL_SERVER_ERROR_MESSAGE)

      expect(json["metadata"]).to be_present
      expect(json["metadata"]["path"]).to eq("/api/v1/products")
      expect(json["metadata"]["statusCode"]).to eq(500)
      expect(json["metadata"]["requestId"]).to be_present
      expect(json["metadata"]["occurredAt"]).to be_present
    end
  end
end
