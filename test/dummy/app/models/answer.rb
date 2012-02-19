class Answer < ActiveRecord::Base
  belongs_to :question
  acts_as_sequenced :scope => :question_id
end
