class CreatePolicemen < ActiveRecord::Migration[4.2]
  def change
    create_table :policemen do |t|
      t.integer :sequential_id

      t.timestamps
    end
  end
end
