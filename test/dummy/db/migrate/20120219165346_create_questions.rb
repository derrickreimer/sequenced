class CreateQuestions < ActiveRecord::Migration[4.2]
  def change
    create_table :questions do |t|
      t.string :summary
      t.text :body

      t.timestamps
    end
  end
end
