$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "activerecord-virtual-columns"

require_relative "db_setup"

require "minitest/autorun"

