# Activerecord::VirtualColumns
Use SQL subqueries to eliminate N+1 queries and take advantage of existing model relations.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord-virtual-columns'
```

## Usage
```ruby
class User < ActiveRecord::Base
  include ActiveRecord::VirtualColumns
  has_many :tweets
  virtual_column :tweet_count,
    scope: -> { Tweet.where('user_id = users.id').select('COUNT(*)') },
    method: -> { tweets.count }
end

class Tweet < ActiveRecord::Base
  belongs_to :user
end

# SELECT *, (SELECT COUNT(*) FROM tweets WHERE user_id = users.id) AS tweet_count
user = User.with_vcolumns(:tweet_count).find 1
# loads from memory (does not run query)
user.tweet_count

```

### Transform values from SQL
You may want to select raw SQL values that you then transform in Ruby. For example, JSON:
```ruby
virtual_column :uses_json,
  scope: -> { "'{ \"a\": 1 }'::json" },
  transform: ->(json_string) { JSON.load json_string }
```

### Enforce the use of the scope
If no `method` is provided, `MethodNotImplementedError` will be raised, thus forcing users to preload using the `scope` form.

### Gotchas
The methods in [ActiveRecord::Calculations](https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html) do not function as lazy scopes, rather they immediately execute a query. Because of this, if you want to make a calculation as part of your virtual column, use a raw SQL snippet:
```ruby
# .maximum(:value) won't work here!
virtual_column :best_score,
  scope: -> { Score.where('user_id = users.id').select('MAX(value)') }
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rigoleto/activerecord-virtual-columns.

Please add tests.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
