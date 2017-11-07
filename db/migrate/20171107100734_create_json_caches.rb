class CreateJsonCaches < ActiveRecord::Migration[5.1]
  def change
    create_table :json_caches do |t|
      t.string :url
      t.binary :json

      t.timestamps
    end
  end
end
