class Comment < ActiveRecord::Base
  belongs_to :question
  acts_as_sequenced :scope => :question_id
  
  def self.default_scope
    order("question_id ASC")
  end
end
