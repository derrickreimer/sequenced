class CreateConcurrentBadgers < ActiveRecord::Migration[4.2]
  def change
    create_table :concurrent_badgers do |t|
      t.integer :sequential_id, null: false
      t.integer :burrow_id
    end

    add_index :concurrent_badgers, [:sequential_id, :burrow_id], unique: true, name: 'unique_concurrent'
  end
end
