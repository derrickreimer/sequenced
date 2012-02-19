class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :product
      t.references :account
      
      t.timestamps
    end
  end
end
