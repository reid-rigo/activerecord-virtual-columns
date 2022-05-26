ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT)

conn = ActiveRecord::Base.connection

conn.execute <<MIGRATE_USERS
  CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT
  )
MIGRATE_USERS
conn.execute <<MIGRATE_TWEETS
  CREATE TABLE tweets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    published BOOLEAN DEFAULT FALSE,
    content TEXT
  )
MIGRATE_TWEETS
conn.execute <<MIGRATE_RETWEETS
  CREATE TABLE retweets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    tweet_id INTEGER NOT NULL
  )
MIGRATE_RETWEETS

class Tweet < ActiveRecord::Base
  belongs_to :user
  has_many :retweets
  scope :published, -> { where(published: true) }
end

class Retweet < ActiveRecord::Base
  belongs_to :tweet
  belongs_to :user
end

class User < ActiveRecord::Base
  include ActiveRecord::VirtualColumns
  has_many :tweets
  has_many :retweets, through: :tweets
  virtual_column :tweet_count,
    scope: -> { Tweet.where('user_id = users.id').select('COUNT(*)') },
    method: -> { tweets.count }
  virtual_column :published_tweet_count,
    scope: -> { Tweet.published.where('user_id = users.id').select('COUNT(*)') },
    method: -> { tweets.published.count }
  virtual_column :tweet_ids,
    scope: -> { Tweet.where('user_id = users.id').select(:id) },
    method: -> { tweets.pluck(:id) }
  virtual_column :retweeted_count,
    scope: -> { Retweet.joins(:tweet).where('tweets.user_id = users.id').select('COUNT(*)') },
    method: -> { retweets.count }
  virtual_column :json_test,
    scope: -> { "json('{ \"a\": 1 }')" },
    transform: ->(json_string) { JSON.load json_string },
    method: -> { { "a" => 1 } }
  virtual_column :scope_only, scope: -> { 'test' }
end

