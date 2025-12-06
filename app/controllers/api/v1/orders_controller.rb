module Api
  module V1
    class OrdersController < ApplicationController

      # GET /api/v1/orders
      def index
        orders = Order.all
        render_success(orders)
      end

      # GET /api/v1/orders/:id
      def show
        order = Order.find(params[:id])
        render_success(order)
      end

      # POST /api/v1/orders
      def create
        order = Order.new(order_params)

        if order.save
          render_success(order, status: :created)
        else
          render_error(order.errors.full_messages, status: :unprocessable_entity)
        end
      end

      # PUT/PATCH /api/v1/orders/:id
      def update
        order = Order.find(params[:id])

        if order.update(order_params)
          render_success(order)
        else
          render_error(order.errors.full_messages, status: :unprocessable_entity)
        end
      end

      # DELETE /api/v1/orders/:id
      def destroy
        order = Order.find(params[:id])
        order.destroy

        render_success({ status: :no_content })
      end

      # GET /api/v1/customer/:customer_id/orders
      def customer_orders
        customer = Customer.find(params[:customer_id])
        render_success(customer.orders)
      end

      private

      def order_params
        params.require(:order)
              .permit(
                :customer_id,
                :status,
                :total_amount
              )
      end

    end
  end
end
