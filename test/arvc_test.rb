require "test_helper"

class ArvcTest < MiniTest::Test

  def setup
    user_1 = User.create!(name: 'User 1')
    tweet_1 = Tweet.create!(user: user_1, published: false, content: 'Draft tweet')
    Tweet.create!(user: user_1, published: true, content: 'Published tweet')
    user_2 = User.create!(name: 'User 2')
    Retweet.create!(user: user_2, tweet: tweet_1)
  end

  def teardown
    Retweet.delete_all
    Tweet.delete_all
    User.delete_all
  end

  def test_vcolumn_from_method
    user = User.first
    assert_equal 2, user.tweet_count
  end

  def test_vcolumn_from_sql
    user = User.with_vcolumns(:tweet_count).first
    assert_equal 2, user.tweet_count
  end

  def test_with_scope
    user = User.with_vcolumns(:published_tweet_count).first
    assert_equal 1, user.published_tweet_count
  end

  def test_with_join
    user = User.with_vcolumns(:retweeted_count).first
    assert_equal 1, user.retweeted_count
  end

  def test_with_mulitple
    users = User.with_vcolumns(:tweet_count).order(:id)
    assert_equal [2, 0], users.map(&:tweet_count)
  end

  def test_with_select
    user = User.with_vcolumns(:tweet_count, select: :tweet_count).first
    assert_equal 2, user.tweet_count
    assert_nil user.id
  end

  def test_with_array
    users = User.with_vcolumns(:tweet_count).order(:id)
    assert_equal 2, users.first.tweet_ids.size
    assert_equal 0, users.last.tweet_ids.size
  end

  def test_with_transform
    user = User.with_vcolumns(:json_test).first
    assert_equal({ "a" => 1 }, user.json_test)
  end

  def test_without_method
    user = User.new
    assert_raises(ActiveRecord::VirtualColumns::MethodNotImplementedError) { user.scope_only }
  end

end