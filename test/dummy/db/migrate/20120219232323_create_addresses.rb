class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.references :account
      t.string :city
      t.timestamps
    end
  end
end
