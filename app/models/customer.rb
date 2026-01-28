class Customer < ApplicationRecord
  has_many :orders, dependent: :destroy

  before_validation :normalize_phone

  validates :name, presence: true

  validates :email, presence: true,
          format: {
            with: URI::MailTo::EMAIL_REGEXP,
            message: "is not a valid email address"
          }

  validates :phone, allow_blank: true,
            format: {
              with: /\A[\d\s\-\+\(\)]*\z/,
              message: "must contain only numbers and valid phone characters"
            }

  private

  def normalize_phone
    return if phone.blank?
    return if phone.match?(/[a-zA-Z]/)

    self.phone = phone.gsub(/\D/, "")
  end
end
