class Promotable < ActiveRecord::Base
	attr_accessible :sequential_id,:name,:boss_id
	acts_as_sequenced :scope=>:boss_id
end
