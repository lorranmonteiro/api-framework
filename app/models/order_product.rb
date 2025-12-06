class OrderProduct < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :price, presence: true

  after_save :update_order_total
  after_destroy :update_order_total

  before_validation :set_default_price, on: :create

  private

  def update_order_total
    order.set_total!
  end

  def set_default_price
    self.price ||= product.price
  end
end
