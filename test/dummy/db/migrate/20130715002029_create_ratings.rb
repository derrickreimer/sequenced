class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.references :comment
      t.integer :score
      t.integer :sequential_id
      t.timestamps
    end
  end
end
