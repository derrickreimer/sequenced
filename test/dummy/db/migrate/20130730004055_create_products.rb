class CreateProducts < ActiveRecord::Migration[4.2]
  def change
    create_table :products do |t|
      t.references :account
      t.integer :sequential_id
      t.timestamps
    end
  end
end
