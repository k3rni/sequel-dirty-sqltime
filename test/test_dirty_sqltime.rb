require 'sequel'
require "minitest/autorun"

# db = Sequel.sqlite
# db = Sequel.mysql2 host: "127.0.0.1", username: "whatever", database: "yourdb"
# db = Sequel.postgres host: "127.0.0.1", username: "whatever", password: "password", database: "yourdb"

db.create_table :time_ranges do
  primary_key :id
  Time :start, only_time: true
  Time :end, only_time: true
end unless db.tables.include? :time_ranges

class TimeRange < Sequel::Model
  plugin :dirty
end

class DirtySQLTime < Minitest::Test
  def test_column_is_sqltime
    obj = TimeRange.create(start: "0:30", end: "21:37")
    assert_kind_of(Sequel::SQLTime, obj.start, "Expected start column to be a SQLTime")
  end

  def test_fetched_column_is_sqltime
    TimeRange.create(start: "0:30", end: "21:37")
    obj = TimeRange.first
    assert_kind_of(Sequel::SQLTime, obj.start, "Expected start column to be a SQLTime")
  end

  def test_sqltime_on_created
    obj = TimeRange.create(start: "0:30", end: "21:37")
    assert_equal({}, obj.column_changes, "Expected column_changes to be empty")

    obj.set(start: "9:30")
    refute_equal({}, obj.column_changes, "Expected column_changes not to be empty")
    prev, curr = obj.column_changes[:start]
    assert_kind_of(Sequel::SQLTime, prev, "Expected previous value to be a SQLTime")
    assert_kind_of(Sequel::SQLTime, curr, "Expected current value to be a SQLTime")
  end

  def test_changes_sqltime_on_read
    TimeRange.create(start: "0:30", end: "21:37")
    obj = TimeRange.first

    obj.set(start: "9:30")
    refute_equal({}, obj.column_changes, "Expected column_changes not to be empty")
    prev, curr = obj.column_changes[:start]
    assert_kind_of(Sequel::SQLTime, prev, "Expected previous value to be a SQLTime")
    assert_kind_of(Sequel::SQLTime, curr, "Expected current value to be a SQLTime")
  end
end
