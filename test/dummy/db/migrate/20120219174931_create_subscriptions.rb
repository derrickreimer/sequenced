class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.string :plan
      t.integer :sequential_id

      t.timestamps
    end
  end
end
