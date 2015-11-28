class ConcurrentBadger < ActiveRecord::Base
  acts_as_sequenced scope: :burrow_id
end
