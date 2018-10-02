class CreateRatings < ActiveRecord::Migration[4.2]
  def change
    create_table :ratings do |t|
      t.references :comment
      t.integer :score
      t.integer :sequential_id
      t.timestamps
    end
  end
end
