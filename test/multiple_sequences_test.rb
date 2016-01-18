require 'test_helper'

class MultipleSequencesTest < ActiveSupport::TestCase
  test "works with simple multiple sequences" do
    doppelganger = Doppelganger.create
    assert_equal 1, doppelganger.sequential_id_one
    assert_equal 1, doppelganger.sequential_id_two
  end
end
