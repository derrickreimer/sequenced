class User < ActiveRecord::Base
	attr_accessible :account_id,:name,:custom_sequential_id

  belongs_to :account
  acts_as_sequenced :scope => :account_id, :column => :custom_sequential_id
end
