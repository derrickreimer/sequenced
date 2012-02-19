class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :summary
      t.text :body

      t.timestamps
    end
  end
end
