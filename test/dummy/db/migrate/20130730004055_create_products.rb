class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.integer :account_id
      t.integer :sequential_id
      t.timestamps
    end
  end
end
