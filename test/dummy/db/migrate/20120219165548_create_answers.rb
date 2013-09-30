class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.integer :question_id
      t.text :body
      t.integer :sequential_id

      t.timestamps
    end
    add_index :answers, :question_id
    add_index :answers, :sequential_id
  end
end
