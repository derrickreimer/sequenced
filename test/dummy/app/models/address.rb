class Address < ActiveRecord::Base
  belongs_to :account
  acts_as_sequenced :scope => :account_id
end
