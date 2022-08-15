require "test_helper"

# Test Models:
#
#   Answer       - :scope => :question_id
#   Comment      - :scope => :question_id (with an AR default scope)
#   Invoice      - :scope => :account_id, :start_at => 1000
#   Product      - :scope => :account_id, :start_at => lambda { |r| r.computed_start_value }
#   Order        - :scope => :non_existent_column
#   User         - :scope => :account_id, :column => :custom_sequential_id
#   Address      - :scope => :account_id ('sequential_id' does not exist)
#   Email        - :scope => [:emailable_id, :emailable_type]
#   Subscription - no options
#   Rating       - :scope => :comment_id, skip: { |r| r.score == 0 }
#   Monster      - no options
#   Zombie       - STI, inherits from Monster
#   Werewolf     - STI, inherits from Monster

#   ConcurrentBadger - scope: :concurrent_burrow_id,
#                      NOT NULL constraint on sequential_id,
#                      UNIQUE constraint on sequential_id within concurrent_burrow_id scope

if ENV["DB"] == "postgresql"
  class ConcurrencyTest < ActiveSupport::TestCase
    self.use_transactional_tests = false

    def setup
      ConcurrentBadger.delete_all
    end

    def teardown
      ConcurrentBadger.delete_all
    end

    test "creates records concurrently without data races" do
      Thread.abort_on_exception = true
      range = (1..50)

      threads = []
      range.each do
        threads << Thread.new do
          ConcurrentBadger.create!(burrow_id: 1)
        end
      end

      threads.each(&:join)

      sequential_ids = ConcurrentBadger.pluck(:sequential_id)
      assert_equal range.to_a, sequential_ids
    end

    test "does not affect saving multiple records within a transaction" do
      range = (1..10)

      ConcurrentBadger.transaction do
        range.each do
          ConcurrentBadger.create!(burrow_id: 1)
        end
      end

      sequential_ids = ConcurrentBadger.pluck(:sequential_id)
      assert_equal range.to_a, sequential_ids
    end

    test "does not affect saving multiple records within nested transactons" do
      range = (1..10)

      ConcurrentBadger.transaction do
        ConcurrentBadger.transaction do
          ConcurrentBadger.transaction do
            range.each do
              ConcurrentBadger.create!(burrow_id: 1)
            end
          end
        end
      end

      sequential_ids = ConcurrentBadger.pluck(:sequential_id)
      assert_equal range.to_a, sequential_ids
    end
  end
end
