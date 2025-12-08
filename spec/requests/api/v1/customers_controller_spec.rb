require 'rails_helper'

RSpec.describe "Api::V1::CustomersController", type: :request do
  let!(:customer1) { Customer.create!(name: "John Doe", email: "john@example.com", phone: "123456") }
  let!(:customer2) { Customer.create!(name: "Jane Doe", email: "jane@example.com", phone: "654321") }

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
      it "returns a NOT_FOUND error using render_error" do
        get "#{base_url}/99999"

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)

        expect(json["message"]).to eq("Record not found")
        expect(json["errorType"]).to eq("NOT_FOUND")

        expect(json["requestDetails"]).to be_present
        expect(json["requestDetails"]["path"]).to eq("/api/v1/customers/99999")
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
      it "returns render_error with message as array" do
        post base_url, params: invalid_params

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)

        expect(json["message"]).to be_an(Array)
        expect(json["message"]).to include("Name can't be blank")

        expect(json["errorType"]).to be_nil

        expect(json["requestDetails"]).to be_present
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
      it "returns validation errors using render_error" do
        patch "#{base_url}/#{customer1.id}", params: {
          customer: { email: "" }
        }

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)

        expect(json["message"]).to be_an(Array)
        expect(json["message"].first).to include("Email can't be blank")

        expect(json["errorType"]).to be_nil

        expect(json["requestDetails"]).to be_present
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

      expect(json["message"]).to eq("Record not found")
      expect(json["errorType"]).to eq("NOT_FOUND")
    end
  end
end
