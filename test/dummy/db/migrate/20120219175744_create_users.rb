class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.references :account
      t.string :name
      t.integer :custom_sequential_id

      t.timestamps
    end
    add_index :users, :account_id
  end
end
