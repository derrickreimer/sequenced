ActiveRecord::Schema.define do
  create_table :questions, force: true do |t|
    t.string :summary
    t.text :body
  end

  create_table :answers, force: true do |t|
    t.references :question
    t.text :body
    t.integer :sequential_id
    t.index :sequential_id
  end

  create_table :accounts, force: true do |t|
    t.string :name
  end

  create_table :invoices, force: true do |t|
    t.integer :amount
    t.integer :sequential_id
    t.references :account
  end

  create_table :orders, force: true do |t|
    t.string :product
    t.references :account
  end

  create_table :subscriptions, force: true do |t|
    t.string :plan
    t.integer :sequential_id
  end

  create_table :users, force: true do |t|
    t.references :account
    t.string :name
    t.integer :custom_sequential_id
  end

  create_table :addresses, force: true do |t|
    t.references :account
    t.string :city
  end

  create_table :comments, force: true do |t|
    t.references :question
    t.text :body
    t.integer :sequential_id
  end

  create_table :emails, force: true do |t|
    t.string :emailable_type
    t.integer :emailable_id
    t.integer :sequential_id
    t.string :address
  end

  create_table :ratings, force: true do |t|
    t.references :comment
    t.integer :score
    t.integer :sequential_id
  end

  create_table :products, force: true do |t|
    t.references :account
    t.integer :sequential_id
  end

  create_table :monsters, force: true do |t|
    t.integer :sequential_id
    t.string :type
  end

  create_table :policemen, force: true do |t|
    t.integer :sequential_id
  end

  create_table :concurrent_badgers, force: true do |t|
    t.integer :sequential_id, null: false
    t.integer :burrow_id

    t.index [:sequential_id, :burrow_id], unique: true, name: "unique_concurrent"
  end

  create_table :doppelgangers, force: true do |t|
    t.integer :sequential_id_one
    t.integer :sequential_id_two
  end

  create_table :with_custom_primary_keys, force: true, id: :integer, primary_key: :legacy_id do |t|
    t.integer :sequential_id
    t.references :account
  end
end
