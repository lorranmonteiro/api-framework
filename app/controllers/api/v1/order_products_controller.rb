module Api
  module V1
    class OrderProductsController < ApplicationController

      # GET /api/v1/order_products/:id
      def show
        order_product = OrderProduct.find(params[:id])
        render_success(order_product)
      end

      # POST /api/v1/order_products
      def create
        order_product = OrderProduct.new(order_product_params)

        if order_product.save
          render_success(order_product, status: :created)
        else
          render_error(order_product.errors.full_messages, status: :unprocessable_content)
        end
      end

      # PUT or PATCH /api/v1/order_products/:id
      def update
        order_product = OrderProduct.find(params[:id])

        if order_product.update(order_product_params)
          render_success(order_product)
        else
          render_error(order_product.errors.full_messages, status: :unprocessable_content)
        end
      end

      # DELETE /api/v1/order_products/:id
      def destroy
        order_product = OrderProduct.find(params[:id])
        order_product.destroy
        
        head :no_content
      end

      # GET /api/v1/orders/:id/products
      def products_by_order
        order = Order.find(params[:id])
        products = order.products

        render_success(products)
      end

      private

      def order_product_params
        params.require(:order_product)
              .permit(
                :order_id,
                :product_id,
                :quantity,
                :price
              )
      end

    end
  end
end
