class AddCancelledToBasket < ActiveRecord::Migration[5.1]
  def change
    add_column :baskets, :cancelled, :boolean, default: false
  end
end
