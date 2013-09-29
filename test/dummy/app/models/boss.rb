class Boss < ActiveRecord::Base
	attr_accessible :name
	has_many :promotables
end
