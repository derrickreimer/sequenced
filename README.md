# Sequenced

[![.github/workflows/ci.yml](https://github.com/derrickreimer/sequenced/actions/workflows/ci.yml/badge.svg)](https://github.com/derrickreimer/sequenced/actions/workflows/ci.yml)
[![Code Climate](https://codeclimate.com/github/djreimer/sequenced.svg)](https://codeclimate.com/github/djreimer/sequenced)
[![Gem Version](https://badge.fury.io/rb/sequenced.svg)](http://badge.fury.io/rb/sequenced)

Sequenced is a simple gem that generates scoped sequential IDs for
ActiveRecord models. This gem provides an `acts_as_sequenced` macro that
automatically assigns a unique, sequential ID to each record. The sequential ID is
not a replacement for the database primary key, but rather adds another way to
retrieve the object without exposing the primary key.

## Purpose

It's generally a bad practice to expose your primary keys to the world
in your URLs. However, it is often appropriate to number objects in sequence
(in the context of a parent object).

For example, given a Question model that has many Answers, it makes sense
to number answers sequentially for each individual question. You can achieve
this with Sequenced in one line of code:

```ruby
class Question < ActiveRecord::Base
  has_many :answers
end

class Answer < ActiveRecord::Base
  belongs_to :question
  acts_as_sequenced scope: :question_id
end
```

## Requirements

- Ruby 2.7+
- Rails 5.2+

## Installation

Add the gem to your Gemfile:

    gem 'sequenced'

Install the gem with bundler:

    bundle install

## Usage

To add a sequential ID to a model, first add an integer column called
`sequential_id` to the model (or you many name the column anything you
like and override the default). For example:

    rails generate migration add_sequential_id_to_answers sequential_id:integer
    rake db:migrate

Then, call the `acts_as_sequenced` macro in your model class:

```ruby
class Answer < ActiveRecord::Base
  belongs_to :question
  acts_as_sequenced scope: :question_id
end
```

The `scope` option can be any attribute, but will typically be the foreign
key of an associated parent object. You can even scope by multiple columns
for polymorphic relationships:

```ruby
class Answer < ActiveRecord::Base
  belongs_to :questionable, :polymorphic => true
  acts_as_sequenced scope: [:questionable_id, :questionable_type]
end
```

Multiple sequences can be defined by using the macro multiple times:

```ruby
class Answer < ActiveRecord::Base
  belongs_to :account
  belongs_to :question

  acts_as_sequenced column: :question_answer_number, scope: :question_id
  acts_as_sequenced column: :account_answer_number, scope: :account_id
end
```

## Schema and data integrity

**This gem is only concurrent-safe for PostgreSQL databases**. For other database systems, unexpected behavior may occur if you attempt to create records concurrently.

You can mitigate this somewhat by applying a unique index to your sequential ID column (or a multicolumn unique index on sequential ID and scope columns, if you are using scopes). This will ensure that you can never have duplicate sequential IDs within a scope, causing concurrent updates to instead raise a uniqueness error at the database-level.

It is also a good idea to apply a not-null constraint to your sequential ID column as well if you never intend to skip it.

Here is an example migration for a model that has a `sequential_id` scoped to a `burrow_id`:

```ruby
# app/db/migrations/20151120190645_create_badgers.rb
class CreateBadgers < ActiveRecord::Migration
  def change
    create_table :badgers do |t|
      t.integer :sequential_id, null: false
      t.integer :burrow_id
    end

    add_index :badgers, [:sequential_id, :burrow_id], unique: true
  end
end
```

If you are adding a sequenced column to an existing table, you need to account for that in your migration.

Here is an example migration that adds and sets the `sequential_id` column based on the current database records:
```ruby
# app/db/migrations/20151120190645_add_sequental_id_to_badgers.rb
class AddSequentalIdToBadgers < ActiveRecord::Migration
  add_column :badgers, :sequential_id, :integer

  execute <<~SQL
    UPDATE badgers
    SET sequential_id = old_badgers.next_sequential_id
    FROM (
      SELECT id, ROW_NUMBER()
      OVER(
        PARTITION BY burrow_id
        ORDER BY id
      ) AS next_sequential_id
      FROM badgers
    ) old_badgers
    WHERE badgers.id = old_badgers.id
  SQL

  change_column :badgers, :sequential_id, :integer, null: false
  add_index :badgers, [:sequential_id, :burrow_id], unique: true
end
```

## Configuration

### Overriding the default sequential ID column

By default, Sequenced uses the `sequential_id` column and assumes it already
exists. If you wish to store the sequential ID in different integer column,
simply specify the column name with the `column` option:

```ruby
acts_as_sequenced scope: :question_id, column: :my_sequential_id
```

### Starting the sequence at a specific number

By default, Sequenced begins sequences with 1. To start at a different
integer, simply set the `start_at` option:

```ruby
acts_as_sequenced start_at: 1000
```

You may also pass a lambda to the `start_at` option:

```ruby
acts_as_sequenced start_at: lambda { |r| r.computed_start_value }
```

### Indexing the sequential ID column

For optimal performance, it's a good idea to index the sequential ID column
on sequenced models.

### Skipping sequential ID generation

If you'd like to skip generating a sequential ID under certain conditions,
you may pass a lambda to the `skip` option:

```ruby
acts_as_sequenced skip: lambda { |r| r.score == 0 }
```

## Example

Suppose you have a question model that has many answers. This example
demonstrates how to use Sequenced to enable access to the nested answer
resource via its sequential ID.

```ruby
# app/models/question.rb
class Question < ActiveRecord::Base
  has_many :answers
end

# app/models/answer.rb
class Answer < ActiveRecord::Base
  belongs_to :question
  acts_as_sequenced scope: :question_id

  # Automatically use the sequential ID in URLs
  def to_param
    self.sequential_id.to_s
  end
end

# config/routes.rb
resources :questions do
  resources :answers
end

# app/controllers/answers_controller.rb
class AnswersController < ApplicationController
  def show
    @question = Question.find(params[:question_id])
    @answer = @question.answers.find_by(sequential_id: params[:id])
  end
end
```

Now, answers are accessible via their sequential IDs:

    http://example.com/questions/5/answers/1  # Good

instead of by their primary keys:

    http://example.com/questions/5/answer/32454  # Bad

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
