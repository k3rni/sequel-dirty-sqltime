# Reproducing the problem

1. Have a model with time-only fields (created with `Time :column, only_time: true`)
2. Have that model use the [dirty plugin](http://sequel.jeremyevans.net/rdoc-plugins/classes/Sequel/Plugins/Dirty.html), or load it for all models
3. Fetch a model instance, update one of the time-only fields
4. Call `#column_changes`, which returns a hash keying column name to a pair of (old, new) values.

Expected result: Both old and new value are `Sequel::SQLTime` instances.
Actual result: Old value is a regular `Time` in the default timezone, new value is a `Sequel::SQLTime`

Note that this happens exclusively on MySQL, postgres and sqlite behave as expected.
