class CreateAddresses < ActiveRecord::Migration[4.2]
  def change
    create_table :addresses do |t|
      t.references :account
      t.string :city
      t.timestamps
    end
  end
end
