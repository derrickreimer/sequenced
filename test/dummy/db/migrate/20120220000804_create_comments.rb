class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :question_id
      t.text :body
      t.integer :sequential_id

      t.timestamps
    end
    add_index :comments, :question_id
  end
end
