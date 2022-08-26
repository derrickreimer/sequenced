class Account < ActiveRecord::Base
  has_many :users
  has_many :invoices
  has_many :orders
  has_many :addresses
end

class Address < ActiveRecord::Base
  belongs_to :account
  acts_as_sequenced scope: :account_id
end

class Answer < ActiveRecord::Base
  belongs_to :question
  acts_as_sequenced scope: :question_id
end

class Comment < ActiveRecord::Base
  belongs_to :question
  acts_as_sequenced scope: :question_id

  def self.default_scope
    order("question_id ASC")
  end
end

class ConcurrentBadger < ActiveRecord::Base
  acts_as_sequenced scope: :burrow_id
end

class Doppelganger < ActiveRecord::Base
  acts_as_sequenced column: :sequential_id_one
  acts_as_sequenced column: :sequential_id_two, start_at: 1000
end

class Email < ActiveRecord::Base
  belongs_to :emailable, polymorphic: true
  acts_as_sequenced scope: [:emailable_id, :emailable_type]
end

class Invoice < ActiveRecord::Base
  belongs_to :account
  acts_as_sequenced scope: :account_id, start_at: 1000
end

class Monster < ActiveRecord::Base
  acts_as_sequenced
end

class Werewolf < Monster
end

class Zombie < Monster
end

class Order < ActiveRecord::Base
  belongs_to :account
  acts_as_sequenced scope: :non_existent_column
end

class Policeman < ActiveRecord::Base
  acts_as_sequenced

  validates :sequential_id, presence: true
end

class Product < ActiveRecord::Base
  belongs_to :account
  acts_as_sequenced scope: :account_id, start_at: lambda { |r| r.computed_start_value }

  def computed_start_value
    1 + 2
  end
end

class Question < ActiveRecord::Base
  has_many :answers
  has_many :comments
end

class Rating < ActiveRecord::Base
  acts_as_sequenced scope: :comment_id, skip: lambda { |r| r.score == 0 }
end

class Subscription < ActiveRecord::Base
  acts_as_sequenced
end

class User < ActiveRecord::Base
  belongs_to :account
  acts_as_sequenced scope: :account_id, column: :custom_sequential_id
end

class WithCustomPrimaryKey < ActiveRecord::Base
  self.primary_key = :legacy_id

  belongs_to :account
  acts_as_sequenced scope: :account_id
end
