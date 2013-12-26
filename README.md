# Sequenced

[![Build Status](https://travis-ci.org/djreimer/sequenced.png)](https://travis-ci.org/djreimer/sequenced)
[![Code Climate](https://codeclimate.com/github/djreimer/sequenced.png)](https://codeclimate.com/github/djreimer/sequenced)
[![Gem Version](https://badge.fury.io/rb/sequenced.png)](http://badge.fury.io/rb/sequenced)

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
    self.sequential_id
  end
end

# config/routes.rb
resources :questions do
  resources :answers
end

# app/controllers/answers_controller.rb
class AnswersController < ApplicationController
  before_filter :load_question
  before_filter :load_answer, only: [:show, :edit, :update, :destroy]
  
private

  def load_question
    @question = Question.find(params[:question_id])
  end
  
  def load_answer
    @answer = @question.answers.where(:sequential_id => params[:id]).first
  end
end
```

Now, answers are accessible via their sequential IDs:

    http://example.com/questions/5/answers/1    # Good

instead of by their primary keys:

    http://example.com/questions/5/answer/32454  # Bad

## License

Copyright &copy; 2011-2014 Derrick Reimer

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
