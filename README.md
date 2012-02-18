# Sequenced

Sequenced is a simple Rails 3 engine that generates scoped sequential 
IDs for ActiveRecord models. It's generally a bad practice to expose your 
database primary keys to the world in your URLs. Sequenced allows you to 
mitigate this problem by sequencing your models within a particular scope. 

For example, given a Question model that has many Answers, it makes sense
to number answers sequentially within the scope of the parent question. 
You can achieve this with Sequenced in one line of code:

```ruby
class Question < ActiveRecord::Base
  has_many :answers
end

class Answer < ActiveRecord::Base
  belongs_to :question
  acts_as_sequenced :on => :question
end
```

## Installation

1. Add the gem to your Gemfile:

```    
gem 'sequenced'
```
    
2. Install and run migrations:

```
rails generate sequenced
rake db:migrate
```

## Usage

To convert a 

## License

Copyright 2012 Derrick Reimer

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