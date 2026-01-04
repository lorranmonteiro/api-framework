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
        product = Product.create!(product_params)
        render_success(product, status: :created)
      end

      # PUT or PATCH /api/v1/products/:id
      def update
        product = Product.find(params[:id])
        product.update!(product_params)
        render_success(product)
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
