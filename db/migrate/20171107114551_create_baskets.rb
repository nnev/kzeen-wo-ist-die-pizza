class CreateBaskets < ActiveRecord::Migration[5.1]
  def change
    create_table :baskets do |t|
      t.datetime :submitted_at
      t.datetime :arrived_at
      t.integer :branch_id

      t.timestamps
    end
  end
end
