require "rails_helper"

RSpec.describe Order, type: :model do
  let(:customer) { Customer.create!(name: "John Doe", email: "john@example.com") }

  describe "associations" do
    it { should belong_to(:customer) }
    it { should have_many(:order_products).dependent(:destroy) }
    it { should have_many(:products).through(:order_products) }
  end

  describe "validations" do
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:total_amount) }
    it { should validate_numericality_of(:total_amount).is_greater_than_or_equal_to(0.0) }
  end

  describe "enum status" do
    it "defines the expected enum values" do
      expect(Order.statuses).to eq(
        "new_order"   => "New",
        "in_progress" => "In progress",
        "done"        => "Done"
      )
    end
  end

  describe "#set_total!" do
    let!(:product1) { Product.create!(name: "Prod 1", price: 10.00) }
    let!(:product2) { Product.create!(name: "Prod 2", price: 15.50) }

    let!(:order) do
      Order.create!(customer: customer, status: "New", total_amount: 0)
    end

    before do
      order.order_products.create!(product: product1, quantity: 2, price: product1.price)
      order.order_products.create!(product: product2, quantity: 1, price: product2.price)
    end

    it "calculates the total based on product prices × quantity" do
      order.set_total!
      order.reload

      expected_total = (10.00 * 2) + (15.50 * 1)
      expect(order.total_amount.to_f).to eq(expected_total)
    end
  end
end
