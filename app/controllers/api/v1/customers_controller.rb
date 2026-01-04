module Api
  module V1
    class CustomersController < ApplicationController

      # GET /api/v1/customers
      def index
        customers = Customer.all
        render_success(customers, status: :ok)
      end

      # GET /api/v1/customers/:id
      def show
        customer = Customer.find(params[:id])
        render_success(customer, status: :ok)
      end

      # POST /api/v1/customers
      def create
        customer = Customer.create!(customer_params)
        render_success(customer, status: :created)
      end

      # PATCH/PUT /api/v1/customers/:id
      def update
        customer = Customer.update!(params[:id], customer_params)
        render_success(customer)
      end

      # DELETE /api/v1/customers/:id
      def destroy
        customer = Customer.find(params[:id])
        customer.destroy

        head :no_content
      end

      private

      def customer_params
        params.require(:customer).permit(:name, :email, :phone)
      end

    end
  end
end
