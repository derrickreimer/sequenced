class Invoice < ActiveRecord::Base
  belongs_to :account
  acts_as_sequenced :scope => :account_id, :start_at => 1000
end
