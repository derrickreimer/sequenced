class Order < ActiveRecord::Base
  belongs_to :account
  acts_as_sequenced scope: :non_existent_column
end
