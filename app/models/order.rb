class Order < ApplicationRecord
  belongs_to :customer

  validates :status, presence: true
  validates :total_amount, presence: true
end
