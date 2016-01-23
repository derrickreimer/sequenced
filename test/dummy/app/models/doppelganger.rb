class Doppelganger < ActiveRecord::Base
  acts_as_sequenced column: :sequential_id_one
  acts_as_sequenced column: :sequential_id_two, start_at: 1000
end
