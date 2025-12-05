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
        customer = Customer.new(customer_params)

        if customer.save
          render_success(customer, status: :created)
        else
          render_error(customer.errors.full_messages, status: :unprocessable_entity)
        end
      end

      # PATCH/PUT /api/v1/customers/:id
      def update
        customer = Customer.find(params[:id])

        if customer.update(customer_params)
          render_success(customer)
        else
          render_error(customer.errors.full_messages, status: :unprocessable_entity)
        end
      end

      # DELETE /api/v1/customers/:id
      def destroy
        customer = Customer.find(params[:id])
        customer.destroy

        render_success(status: :no_content)
      end

      private

      def customer_params
        params.require(:customer).permit(:name, :email, :phone)
      end

    end
  end
end
