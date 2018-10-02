class CreateInvoices < ActiveRecord::Migration[4.2]
  def change
    create_table :invoices do |t|
      t.integer :amount
      t.integer :sequential_id
      t.references :account

      t.timestamps
    end
    add_index :invoices, :account_id
  end
end
