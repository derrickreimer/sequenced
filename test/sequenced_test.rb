require 'test_helper'

class SequencedTest < ActiveSupport::TestCase
  test "sequential_id_default_start_at" do
    question = Question.create
    answer = question.answers.create
    assert_equal 1, answer.sequential_id
  end
  
  test "sequential_id_custom_start_at" do
    account = Account.create
    invoice = account.invoices.create
    assert_equal 1000, invoice.sequential_id
    
    another_invoice = account.invoices.create
    assert_equal 1001, another_invoice.sequential_id
  end
  
  test "sequential_id_custom_start_at_with_populated_table" do
    account = Account.create
    account.invoices.create(:sequential_id => 1)
    invoice = account.invoices.create
    assert_equal 1000, invoice.sequential_id
  end
  
  test "sequential_id_increment" do
    question = Question.create
    question.answers.create(:sequential_id => 10)
    another_answer = question.answers.create
    assert_equal 11, another_answer.sequential_id
  end
  
  test "default_scope" do
    Subscription.create(:sequential_id => 1)
    subscription = Subscription.create
    assert_equal 2, subscription.sequential_id
  end
  
  test "invalid_scope" do
    account = Account.create
    order = account.orders.build
    assert_raises(Sequenced::InvalidScopeError) { order.save }
  end
  
  test "custom_sequential_id_column" do
    account = Account.create
    user = account.users.create
    assert_equal 1, user.custom_sequential_id
  end
  
  test "sequential_id_remains_on_save" do
    question = Question.create
    answer = question.answers.create
    assert_equal 1, answer.sequential_id
    
    answer.reload
    answer.body = "Updated body"
    answer.save
    assert_equal 1, answer.sequential_id
  end
end
