require 'rails_helper'

RSpec.describe Customer, type: :model do
  describe "associations" do
    it { should have_many(:orders).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
  end

  describe "phone validations & normalization" do
    it "allows phone to be nil (optional field)" do
      customer = build(:customer, phone: nil)
      expect(customer).to be_valid
    end

    it "allows phone to be blank (optional field)" do
      customer = build(:customer, phone: "")
      expect(customer).to be_valid
    end

    it "rejects phone containing letters" do
      customer = build(:customer, phone: "4324abc123")

      expect(customer).not_to be_valid
      expect(customer.errors[:phone]).to include("must contain only numbers and valid phone characters")
    end

    it "normalizes phone with common formatting characters and saves only digits" do
      customer = create(:customer, phone: "+55 (85) 98686-5522")

      expect(customer.reload.phone).to eq("5585986865522")
    end

    it "keeps already-normalized numeric phone as-is" do
      customer = create(:customer, phone: "85999999999")
      expect(customer.reload.phone).to eq("85999999999")
    end
  end

  context "email validations" do
    it "rejects invalid email format" do
      customer = build(:customer, email: "invalid-email")
      expect(customer).not_to be_valid
      expect(customer.errors[:email]).to include("is not a valid email address")
    end

    it "rejects incomplete emails" do
      customer = build(:customer, email: "@test.com")
      expect(customer).not_to be_valid
      expect(customer.errors[:email]).to include("is not a valid email address")
    end

    it "accepts a valid email" do
      customer = build(:customer, email: "user@example.com")
      expect(customer).to be_valid
    end
  end
end
