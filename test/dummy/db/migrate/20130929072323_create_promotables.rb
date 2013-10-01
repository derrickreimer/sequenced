class CreatePromotables < ActiveRecord::Migration
  def change
    create_table :promotables do |t|
      t.integer :sequential_id
      t.integer :boss_id
      t.string :name

      t.timestamps
    end
  end
end
