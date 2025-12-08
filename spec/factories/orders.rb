FactoryBot.define do
  factory :order do
    association :customer

    status       { "New" }
    total_amount { 0.0 }
  end

  trait :with_products do
    after(:create) do |order|
      create_list(:order_product, 3, order: order)
    end
  end

  trait :in_progress do
    status { "In progress" }
  end
end
