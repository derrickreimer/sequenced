require 'test_helper'

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

class ActsAsSequencedTest < ActiveSupport::TestCase
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
  
  test "lambda start_at" do
    account = Account.create
    product = Product.create(:account_id => account.id)
    assert_equal 3, product.sequential_id
    
    another_product = Product.create(:account_id => account.id)
    assert_equal 4, another_product.sequential_id
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
    assert_raises(NoMethodError) { order.save }
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
    assert_raises(NoMethodError) { address.save }
  end
  
  test "manually setting sequential id" do
    question = Question.create
    answer = question.answers.build(:sequential_id => 10)
    another_answer = question.answers.build(:sequential_id => 10)
    answer.save
    another_answer.save
    
    assert_equal 10, answer.sequential_id
    assert_equal 10, another_answer.sequential_id
  end
  
  test "model with a default scope for sorting" do
    question = Question.create
    (1..3).each { |id| question.comments.create(:sequential_id => id) }
    comment = question.comments.create
    assert_equal 4, comment.sequential_id
  end
  
  test "multi-column scopes" do
    Email.create(:emailable_id => 1, :emailable_type => "User", :sequential_id => 2)
    Email.create(:emailable_id => 1, :emailable_type => "Question", :sequential_id => 3)
    email = Email.create(:emailable_id => 1, :emailable_type => "User")
    assert_equal 3, email.sequential_id
  end
  
  test "skip option" do
    rating = Rating.create(:comment_id => 1, :score => 1)
    assert_equal 1, rating.sequential_id
    
    rating = Rating.create(:comment_id => 1, :score => 0)
    assert_equal nil, rating.sequential_id
  end
end
