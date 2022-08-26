require "test_helper"

class MultipleSequencesTest < ActiveSupport::TestCase
  def teardown
    Doppelganger.delete_all
  end

  test "works with simple multiple sequences" do
    doppelganger = Doppelganger.create!
    assert_equal 1, doppelganger.sequential_id_one
    assert_equal 1000, doppelganger.sequential_id_two
  end

  test "raises error on multiple definitions for the same column" do
    assert_raise Sequenced::ActsAsSequenced::SequencedColumnExists do
      Doppelganger.class_eval do
        acts_as_sequenced column: :sequential_id_one, start_at: 99
      end
    end

    doppelganger = Doppelganger.create!
    assert_equal 1, doppelganger.sequential_id_one
  end
end
