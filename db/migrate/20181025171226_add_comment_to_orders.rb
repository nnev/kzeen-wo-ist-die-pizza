class AddCommentToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :comment, :string, limit: 255
  end
end
