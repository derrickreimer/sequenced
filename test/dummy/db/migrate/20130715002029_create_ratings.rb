class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.integer :comment_id
      t.integer :score
      t.integer :sequential_id
      t.timestamps
    end
  end
end
