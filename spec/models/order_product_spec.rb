require 'rails_helper'

RSpec.describe OrderProduct, type: :model do
  describe "associations" do
    it { should belong_to(:order) }
    it { should belong_to(:product) }
  end

  describe "validations" do
    it { should validate_presence_of(:quantity) }
    it { should validate_numericality_of(:quantity).is_greater_than(0) }

    it { should validate_presence_of(:price) }
  end

  describe "callbacks" do
    let(:customer) { Customer.create!(name: "Test", email: "test@example.com") }
    let(:order)    { Order.create!(customer: customer, status: :new_order, total_amount: 0) }
    let(:product)  { Product.create!(name: "Product A", price: 50) }

    it "sets default price on create" do
      op = OrderProduct.create!(
        order: order,
        product: product,
        quantity: 2
      )

      expect(op.price).to eq(50)
    end

    it "updates order total after save" do
      OrderProduct.create!(order: order, product: product, quantity: 2, price: 10)

      expect(order.reload.total_amount).to eq(20)
    end

    it "updates order total after destroy" do
      op = OrderProduct.create!(order: order, product: product, quantity: 2, price: 10)

      expect(order.reload.total_amount).to eq(20)

      op.destroy

      expect(order.reload.total_amount).to eq(0)
    end
  end
end
