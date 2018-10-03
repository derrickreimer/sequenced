class CreateOrders < ActiveRecord::Migration[4.2]
  def change
    create_table :orders do |t|
      t.string :product
      t.references :account

      t.timestamps
    end
  end
end
