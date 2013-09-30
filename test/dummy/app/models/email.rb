class Email < ActiveRecord::Base
	attr_accessible :emailable_id,:emailable_type,:sequential_id,:address
  belongs_to :emailable, :polymorphic => true
  acts_as_sequenced :scope => [:emailable_id, :emailable_type]
end
