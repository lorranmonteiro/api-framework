require "rails_helper"

RSpec.describe "Api::V1::OrdersController", type: :request do
  let!(:customer) { Customer.create!(name: "John Doe", email: "john@example.com") }

  let!(:order1) do
    Order.create!(customer: customer, status: "New", total_amount: 100)
  end

  let!(:order2) do
    Order.create!(customer: customer, status: "In progress", total_amount: 200)
  end

  let(:base_url) { "/api/v1/orders" }

  describe "GET /api/v1/orders" do
    it "returns all orders" do
      get base_url

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json.size).to eq(2)
      expect(json.first["total_amount"].to_f).to eq(100.0)
    end
  end

  describe "GET /api/v1/orders/:id" do
    context "when the order exists" do
      it "returns the order" do
        get "#{base_url}/#{order1.id}"

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json["total_amount"].to_f).to eq(100.0)
      end
    end

    context "when the order does not exist" do
      it "returns NOT_FOUND" do
        get "#{base_url}/99999"

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)

        expect(json["message"]).to eq("Record not found")
        expect(json["errorType"]).to eq("NOT_FOUND")
      end
    end
  end

  describe "POST /api/v1/orders" do
    let(:valid_params) do
      {
        order: {
          customer_id: customer.id,
          status: "New",
          total_amount: 50
        }
      }
    end

    let(:invalid_params) do
      {
        order: {
          customer_id: nil,
          status: "",
          total_amount: -10
        }
      }
    end

    context "with valid params" do
      it "creates an order" do
        post base_url, params: valid_params

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)

        expect(json["status"]).to eq("new_order")
        expect(json["total_amount"].to_f).to eq(50.0)
      end
    end

    context "with invalid params" do
      it "returns validation errors" do
        post base_url, params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)

        expect(json["message"]).to be_an(Array)
        expect(json["message"]).to include("Customer must exist")
        expect(json["message"]).to include("Status can't be blank")
        expect(json["message"]).to include("Total amount must be greater than or equal to 0.0")

        expect(json["errorType"]).to be_nil
        expect(json["requestDetails"]).to be_present
      end
    end
  end

  describe "PATCH /api/v1/orders/:id" do
    context "with valid attributes" do
      it "updates the order" do
        patch "#{base_url}/#{order1.id}", params: {
          order: { status: "Done" }
        }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json["status"]).to eq("done")
      end
    end

    context "with invalid attributes" do
      it "returns validation errors" do
        patch "#{base_url}/#{order1.id}", params: {
          order: { total_amount: -5 }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)

        expect(json["message"]).to be_an(Array)
        expect(json["message"]).to include("Total amount must be greater than or equal to 0.0")
      end
    end
  end

  describe "DELETE /api/v1/orders/:id" do
    it "deletes the order" do
      delete "#{base_url}/#{order1.id}"

      expect(response).to have_http_status(:no_content)
      expect(Order.find_by(id: order1.id)).to be_nil
    end

    it "returns NOT_FOUND when order does not exist" do
      delete "#{base_url}/99999"

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)

      expect(json["message"]).to eq("Record not found")
      expect(json["errorType"]).to eq("NOT_FOUND")
    end
  end

  describe "GET /api/v1/customer/:customer_id/orders" do
    it "returns all orders for a specific customer" do
      get "/api/v1/customer/#{customer.id}/orders"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json.size).to eq(2)
      expect(json.first["customer_id"]).to eq(customer.id)
    end

    it "returns NOT_FOUND when customer does not exist" do
      get "/api/v1/customer/99999/orders"

      expect(response).to have_http_status(:not_found)
    end
  end
end
