class Question < ActiveRecord::Base
	attr_accessible :summary,:body

  has_many :answers
  has_many :comments
end
