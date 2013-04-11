class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.string :emailable_type
      t.integer :emailable_id
      t.integer :sequential_id
      t.string :address

      t.timestamps
    end
  end
end
