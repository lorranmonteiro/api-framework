OrderProduct.delete_all
Order.delete_all
Product.delete_all
Customer.delete_all

customers = [
  { name: "João Silva",   email: "joao.silva@email.com",   phone: "85999990001" },
  { name: "Maria Santos", email: "maria.santos@email.com", phone: "85999990002" },
  { name: "Pedro Alves",  email: "pedro.alves@email.com",  phone: "85999990003" },
  { name: "Ana Costa",    email: "ana.costa@email.com",    phone: "85999990004" },
  { name: "Lucas Rocha",  email: "lucas.rocha@email.com",  phone: "85999990005" }
].map { |attrs| Customer.create!(attrs) }

products_data = [
  { name: "Smartphone",        description: "Celular Android 128GB",  price: 1999.90 },
  { name: "Televisão",         description: "TV LED 50 polegadas 4K", price: 2799.00 },
  { name: "Notebook",          description: "Notebook i5 16GB RAM",   price: 3899.90 },
  { name: "Geladeira",         description: "Geladeira Frost Free",   price: 3299.00 },
  { name: "Ar Condicionado",   description: "Split 12.000 BTUs",      price: 2499.00 },
  { name: "Micro-ondas",       description: "Micro-ondas 30L",        price: 699.90 },
  { name: "Máquina de Lavar",  description: "Lavadora 11kg",          price: 2199.00 },
  { name: "Fone de Ouvido",    description: "Bluetooth Noise Cancel", price: 499.90 },
  { name: "Teclado Mecânico",  description: "RGB Switch Blue",        price: 399.90 },
  { name: "Mouse Gamer",       description: "16000 DPI RGB",          price: 249.90 }
]

products = products_data.map { |attrs| Product.create!(attrs) }

customers.each do |customer|
  rand(2..3).times do
    order = Order.create!(
      customer: customer,
      status: :new_order
    )

    order_products = products.sample(rand(2..4)).map do |product|
      quantity = rand(1..3)

      OrderProduct.create!(
        order: order,
        product: product,
        quantity: quantity,
        price: product.price
      )
    end
  end
end
