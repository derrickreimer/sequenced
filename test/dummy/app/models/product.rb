class Product < ActiveRecord::Base
  belongs_to :account
  acts_as_sequenced scope: :account_id, start_at: lambda { |r| r.computed_start_value }

  def computed_start_value
    1 + 2
  end
end
