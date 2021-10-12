ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

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
    content TEXT
  )
MIGRATE_TWEETS

class Tweet < ActiveRecord::Base
  belongs_to :user
end

class User < ActiveRecord::Base
  include ActiveRecord::VirtualColumns
  has_many :tweets
  virtual_column :tweet_count,
    scope: -> { Tweet.where('user_id = users.id').select('COUNT(*)') },
    method: -> { tweets.count }
end

