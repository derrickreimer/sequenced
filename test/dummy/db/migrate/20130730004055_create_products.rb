class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.references :account
      t.integer :sequential_id
      t.timestamps
    end
  end
end
