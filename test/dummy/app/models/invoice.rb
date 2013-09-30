class Invoice < ActiveRecord::Base
	attr_accessible :sequential_id
  belongs_to :account
  acts_as_sequenced :scope => :account_id, :start_at => 1000
end
