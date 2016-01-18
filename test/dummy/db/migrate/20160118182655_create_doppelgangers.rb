class CreateDoppelgangers < ActiveRecord::Migration
  def change
    create_table :doppelgangers do |t|
      t.integer :sequential_id_one
      t.integer :sequential_id_two

      t.timestamps null: false
    end
  end
end
