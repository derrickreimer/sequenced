class CreateSequences < ActiveRecord::Migration
  def self.up
    create_table :sequences do |t|
      t.string "sequencer_type"
      t.integer "sequencer_id"
      t.string  "sequenced_type"
      t.integer "last_id",        :default => 1
      t.timestamps
    end
  end
  
  def self.down
    drop_table :sequences
  end
end