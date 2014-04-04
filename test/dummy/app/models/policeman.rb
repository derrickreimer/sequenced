class Policeman < ActiveRecord::Base
  acts_as_sequenced

  validates :sequential_id, presence: true
end
