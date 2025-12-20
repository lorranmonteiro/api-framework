require 'rails_helper'

RSpec.describe Product, type: :model do
  describe "associations" do
    it { should have_many(:order_products).dependent(:destroy) }
    it { should have_many(:orders).through(:order_products) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_numericality_of(:price).is_greater_than(0) }
  end
end
