class Answer < ActiveRecord::Base
	attr_accessible :question_id,:sequential_id
  belongs_to :question
  acts_as_sequenced :scope => :question_id
end
