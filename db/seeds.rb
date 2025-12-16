# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

OrderProduct.delete_all
Order.delete_all
Product.delete_all
Customer.delete_all

customers = [
  { name: "João Silva", email: "joao@emal.com", phone: "85999990000" },
  { name: "Maria Santos", email: "maria@emal.com", phone: "85999991111" },
  { name: "Carlos Oliveira", email: "carlos@emal.com", phone: "85999992222" }
].map { |attrs| Customer.create!(attrs) }

products = []
20.times do |i|
  products << Product.create!(
    name: "Prooduct #{i + 1}",
    description: "Product description #{i + 1}",
    price: rand(10.0..200.0).round(2)
  )
end

5.times do
  customer = customers.sample

  order = Order.create!(
    customer_id: customer.id
  )

  products.sample(3).each do |product|
    OrderProduct.create!(
      order_id: order.id,
      product_id: product.id,
      quantity:  rand(1..5),
      price: product.price
    )
  end
end
