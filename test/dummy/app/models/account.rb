class Account < ActiveRecord::Base
  has_many :users
  has_many :invoices
  has_many :orders
  has_many :addresses
end
