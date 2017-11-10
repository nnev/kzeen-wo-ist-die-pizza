class CreateOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :orders do |t|
      t.string :nick
      t.integer :basket_id
      t.boolean :paid, default: false
      t.text :order

      t.timestamps
    end

    add_index :orders, [:nick, :basket_id], unique: true
  end
end
