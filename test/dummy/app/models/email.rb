class Email < ActiveRecord::Base
  belongs_to :emailable, :polymorphic => true
  acts_as_sequenced :scope => [:emailable_id, :emailable_type]
end
