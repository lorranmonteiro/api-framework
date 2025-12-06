class Order < ApplicationRecord
  belongs_to :customer
  has_many :order_products, dependent: :destroy
  has_many :products, through: :order_products

  validates :status, presence: true
  validates :total_amount, presence: true

  enum status: {
    new_order: "New",
    in_progress: "In progress",
    done: "Done"
  }

  def set_total!
    new_total = order_products.sum("price * quantity")
    update!(total_amount: new_total.round(2))
  end
end
