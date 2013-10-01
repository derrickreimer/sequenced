class Account < ActiveRecord::Base
	attr_accessible :name
  has_many :users
  has_many :invoices
  has_many :orders
  has_many :addresses
end
