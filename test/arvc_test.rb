require "test_helper"

class TestIt < MiniTest::Unit::TestCase

  def setup
    user = User.create!(name: 'Tester')
    Tweet.create!(user: user, content: 'Test content')
  end

  def teardown
    Tweet.delete_all
    User.delete_all
  end

  def test_vcolumn_from_method
    user = User.last
    assert_equal 1, user.tweet_count
  end

  def test_vcolumn_from_sql
    user = User.with_vcolumns(:tweet_count).last
    assert_equal 1, user.tweet_count
  end

end