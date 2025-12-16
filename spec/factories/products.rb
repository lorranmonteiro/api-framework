FactoryBot.define do
  factory :product do
    name        { Faker::Commerce.product_name }
    description { Faker::Lorem.sentence }
    price       { Faker::Commerce.price(range: 1.0..200.0) }
  end
end
