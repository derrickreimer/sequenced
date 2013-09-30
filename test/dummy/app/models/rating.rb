class Rating < ActiveRecord::Base
	attr_accessible :comment_id,:score,:sequential_id
  acts_as_sequenced :scope => :comment_id, :skip => lambda { |r| r.score == 0 }
end
