class CreateMonsters < ActiveRecord::Migration
  def change
    create_table :monsters do |t|
      t.integer :sequential_id
      t.string :type
      t.timestamps
    end
  end
end
