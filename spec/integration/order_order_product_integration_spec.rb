require 'rails_helper'

RSpec.describe "Order and OrderProduct Integration", type: :model do
  let!(:customer) { create(:customer) }
  let!(:product1) { create(:product, price: 100) }
  let!(:product2) { create(:product, price: 50) }
  let!(:order)    { create(:order, customer: customer) }

  describe "creating order_products updates order totals" do
    it "updates the total_amount correctly" do
      create(:order_product, order: order, product: product1, quantity: 2, price: 100)
      create(:order_product, order: order, product: product2, quantity: 1, price: 50)

      expect(order.reload.total_amount).to eq(250)
    end
  end

  describe "default price from product" do
    it "sets price = product.price when omitted" do
      op = create(:order_product, order: order, product: product1, quantity: 1)

      expect(op.price).to eq(100)
    end
  end

  describe "destroying an order_product updates the total" do
    it "recalculates order total after destroy" do
      op1 = create(:order_product, order: order, product: product1, quantity: 1, price: 100)
      op2 = create(:order_product, order: order, product: product2, quantity: 2, price: 50)

      expect(order.reload.total_amount).to eq(200)

      op2.destroy

      expect(order.reload.total_amount).to eq(100)
    end
  end

  describe "updating an order_product changes the order total" do
    it "updates totals after updating quantity" do
      op = create(:order_product, order: order, product: product1, quantity: 1, price: 100)

      expect(order.reload.total_amount).to eq(100)

      op.update!(quantity: 3)

      expect(order.reload.total_amount).to eq(300)
    end

    it "updates totals after updating price" do
      op = create(:order_product, order: order, product: product1, quantity: 2, price: 100)

      expect(order.reload.total_amount).to eq(200)

      op.update!(price: 80)

      expect(order.reload.total_amount).to eq(160)
    end
  end

  describe "full lifecycle of order_products" do
    it "correctly handles add → update → delete" do
      op1 = create(:order_product, order: order, product: product1, quantity: 1, price: 100)
      op2 = create(:order_product, order: order, product: product2, quantity: 2, price: 50)

      expect(order.reload.total_amount).to eq(200)

      op2.update!(quantity: 3) # +50

      expect(order.reload.total_amount).to eq(250)

      op1.destroy

      expect(order.reload.total_amount).to eq(150)
    end
  end
end
