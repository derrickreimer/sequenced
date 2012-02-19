class User < ActiveRecord::Base
  belongs_to :account
  acts_as_sequenced :scope => :account_id, :column => :custom_sequential_id
end
