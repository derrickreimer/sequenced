require 'test_helper'

# Test Models:
#
#   Answer       - :scope => :question_id
#   Invoice      - :scope => :account_id, :start_at => 1000
#   Order        - :scope => :non_existent_column
#   User         - :scope => :account_id, :column => :custom_sequential_id
#   Address      - :scope => :account_id ('sequential_id' does not exist)
#   Subscription - no options

class SequencedTest < ActiveSupport::TestCase
  test "default start_at" do
    question = Question.create
    answer = question.answers.create
    assert_equal 1, answer.sequential_id
  end
  
  test "custom start_at" do
    account = Account.create
    invoice = account.invoices.create
    assert_equal 1000, invoice.sequential_id
    
    another_invoice = account.invoices.create
    assert_equal 1001, another_invoice.sequential_id
  end
  
  test "custom start_at with populated table" do
    account = Account.create
    account.invoices.create(:sequential_id => 1)
    invoice = account.invoices.create
    assert_equal 1000, invoice.sequential_id
  end
  
  test "sequential id increment" do
    question = Question.create
    question.answers.create(:sequential_id => 10)
    another_answer = question.answers.create
    assert_equal 11, another_answer.sequential_id
  end
  
  test "default scope" do
    Subscription.create(:sequential_id => 1)
    subscription = Subscription.create
    assert_equal 2, subscription.sequential_id
  end
  
  test "undefined scope method" do
    account = Account.create
    order = account.orders.build
    assert_raises(Sequenced::InvalidAttributeError) { order.save }
  end
  
  test "scope method returns nil" do
    answer = Answer.new
    assert_raises(Sequenced::InvalidAttributeError) { answer.save }
  end
  
  test "custom sequential id column" do
    account = Account.create
    user = account.users.create
    assert_equal 1, user.custom_sequential_id
  end
  
  test "sequential id remains on save" do
    question = Question.create
    answer = question.answers.create
    assert_equal 1, answer.sequential_id
    
    answer.reload
    answer.body = "Updated body"
    answer.save
    assert_equal 1, answer.sequential_id
  end
  
  test "undefined sequential id column" do
    account = Account.create
    address = account.addresses.build
    assert_raises(Sequenced::InvalidAttributeError) { address.save }
  end
  
  test "manually setting sequential id" do
    question = Question.create
    answer = question.answers.build(:sequential_id => 10)
    another_answer = question.answers.build(:sequential_id => 10)
    answer.save
    another_answer.save
    
    assert_equal 10, answer.sequential_id
    assert_equal 11, another_answer.sequential_id
  end
end
