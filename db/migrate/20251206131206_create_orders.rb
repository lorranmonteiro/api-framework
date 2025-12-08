class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :status, default: "New", null: false
      t.decimal :total_amount, default: 0.0, null: false

      t.timestamps
    end
  end
end
