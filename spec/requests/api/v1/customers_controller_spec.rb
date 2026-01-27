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
        expect(error["errorType"]).to eq(ErrorTypes::NOT_FOUND)
        expect(error["message"]).to eq(Constants::RECORD_NOT_FOUND_MESSAGE)

        expect(json["metadata"]).to be_present
        expect(json["metadata"]["path"]).to eq("/api/v1/customers/99999")
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
            "errorType" => ErrorTypes::FIELD_VALIDATION,
            "message" => "Name can't be blank"
          ),
          hash_including(
            "errorType" => ErrorTypes::FIELD_VALIDATION,
            "message" => "Email can't be blank"
          )
        )

        expect(json["metadata"]).to be_present
        expect(json["metadata"]["path"]).to eq("/api/v1/customers")
      end
    end

    context "phone validations & normalization" do
      it "returns validation error when phone contains letters (e.g. '4324abc123')" do
        post base_url, params: {
          customer: {
            name: "Ana",
            email: "ana@example.com",
            phone: "4324abc123"
          }
        }

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)

        expect(json["errors"]).to be_an(Array)

        error = json["errors"].first
        expect(error["errorType"]).to eq(ErrorTypes::FIELD_VALIDATION)
        expect(error["message"]).to eq("Phone must contain only numbers and valid phone characters")
      end

      it "normalizes phone like '(85) 98683-5522' to '85986835522'" do
        post base_url, params: {
          customer: {
            name: "Ana Maria",
            email: "ana.maria@example.com",
            phone: "(85) 98683-5522"
          }
        }

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["phone"]).to eq("85986835522")

        created = Customer.find(json["id"])
        expect(created.phone).to eq("85986835522")
      end

      it "allows creating customer when phone is omitted (optional field)" do
        post base_url, params: {
          customer: {
            name: "No Phone",
            email: "nophone@example.com"
          }
        }

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)

        created = Customer.find(json["id"])
        expect(created.phone).to be_nil
      end

      it "allows creating customer when phone is blank (treated as blank)" do
        post base_url, params: {
          customer: {
            name: "Blank Phone",
            email: "blankphone@example.com",
            phone: ""
          }
        }

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)

        created = Customer.find(json["id"])
        expect(created.phone).to be_blank
      end

      it "normalizes phone with country code '+55 (85) 98686-5522' to '5585986865522'" do
        post base_url, params: {
          customer: {
            name: "Country Code",
            email: "country@example.com",
            phone: "+55 (85) 98686-5522"
          }
        }

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)

        expect(json["phone"]).to eq("5585986865522")
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
          customer: { email: "", phone: "abc123" }
        }

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)

        expect(json["errors"]).to be_an(Array)
        expect(json["errors"].size).to eq(2)

        error = json["errors"].first
        expect(error["errorType"]).to eq(ErrorTypes::FIELD_VALIDATION)
        expect(error["message"]).to eq("Email can't be blank")

        error = json["errors"].second
        expect(error["errorType"]).to eq(ErrorTypes::FIELD_VALIDATION)
        expect(error["message"]).to eq("Phone must contain only numbers and valid phone characters")

        expect(json["metadata"]).to be_present
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
      expect(error["errorType"]).to eq(ErrorTypes::NOT_FOUND)
      expect(error["message"]).to eq(Constants::RECORD_NOT_FOUND_MESSAGE)
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
      expect(error["errorType"]).to eq(ErrorTypes::INTERNAL_SERVER_ERROR)
      expect(error["message"]).to eq(Constants::INTERNAL_SERVER_ERROR_MESSAGE)

      expect(json["metadata"]).to be_present
      expect(json["metadata"]["path"]).to eq("/api/v1/products")
      expect(json["metadata"]["requestId"]).to be_present
      expect(json["metadata"]["occurredAt"]).to be_present
    end
  end
end
