class CreatePolicemen < ActiveRecord::Migration
  def change
    create_table :policemen do |t|
      t.integer :sequential_id

      t.timestamps
    end
  end
end
