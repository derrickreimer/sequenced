class Subscription < ActiveRecord::Base
	attr_accessible :sequential_id
  acts_as_sequenced
end
