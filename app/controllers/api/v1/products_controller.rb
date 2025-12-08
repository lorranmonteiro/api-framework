module Api
  module V1
    class ProductsController < ApplicationController

      # GET /api/v1/products
      def index
        products = Product.all
        render_success(products)
      end

      # GET /api/v1/products/:id
      def show
        product = Product.find(params[:id])
        render_success(product)
      end

      # POST /api/v1/products
      def create
        product = Product.new(product_params)

        if product.save
          render_success(product, status: :created)
        else
          render_error(product.errors.full_messages, status: :unprocessable_content)
        end
      end

      # PUT or PATCH /api/v1/products/:id
      def update
        product = Product.find(params[:id])

        if product.update(product_params)
          render_success(product)
        else
          render_error(product.errors.full_messages, status: :unprocessable_content)
        end
      end

      # DELETE /api/v1/products/:id
      def destroy
        product = Product.find(params[:id])
        product.destroy

        head :no_content
      end

      private

      def product_params
        params.require(:product).permit(:name, :description, :price)
      end

    end
  end
end
