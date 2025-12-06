class AddDefaultsToOrders < ActiveRecord::Migration[8.1]
  def change
    change_column :orders, :total_amount, :decimal, default: 0.0, null: false
    change_column :orders, :status, :string, default: "New", null: false
  end
end
