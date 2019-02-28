class WithCustomPrimaryKey < ActiveRecord::Base
  self.primary_key = :legacy_id

  belongs_to :account
  acts_as_sequenced :scope => :account_id
end
