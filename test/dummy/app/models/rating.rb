class Rating < ActiveRecord::Base
  acts_as_sequenced :scope => :comment_id, :skip => lambda { |r| r.score == 0 }
end
