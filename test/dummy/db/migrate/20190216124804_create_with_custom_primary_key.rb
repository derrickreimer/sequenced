class CreateWithCustomPrimaryKey < ActiveRecord::Migration[5.2]
  def change
    create_table :with_custom_primary_keys, id: :integer, primary_key: :legacy_id do |t|
      t.integer :sequential_id
      t.references :account
    end
  end
end
