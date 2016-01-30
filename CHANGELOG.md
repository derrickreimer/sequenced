3.1.1 (January 30, 2016)
-------------------------

* Rails 3 compatibility
  (samphilipd, [#22](https://github.com/djreimer/sequenced/pull/19))

3.1.0 (January 23, 2016)
-------------------------

* Allow multiple sequences on one record
  (samphilipd, [#19](https://github.com/djreimer/sequenced/pull/19))

3.0.0 (November 28, 2015)
-------------------------

* Make this gem thread-safe for PostgreSQL
  (samphilipd, [#16](https://github.com/djreimer/sequenced/pull/16))

2.0.0 (October 24, 2014)
------------------------

* Revert "Move generation callback from `before_save` to `before_validation` to
  allow validations to utilize the sequential id". This change introduced a
  critical bug where generating multiple records in one transaction would lead
  to duplicate ids (see #10)

1.6.0 (April 10, 2014)
----------------------

* Move generation callback from `before_save` to `before_validation` to
  allow validations to utilize the sequential id (makebytes)

1.5.0 (December 26, 2013)
-------------------------

* Add the ability to pass a lambda for the start_at option (Bobby Uhlenbrock)
* Major internal refactor for cleaner, more modular code
* Scope by base class when single table inheritance is being used (Adam Becker)

1.4.0 (July 15, 2013)
---------------------

* Remove hard dependency on Rails 3 in the test suite
* Add skip option to sequence generation

1.3.0 (April 11, 2013)
----------------------

* Fix a potential bug that could overwrite previously set sequential IDs if
  they are later found to be non-unique.

1.2.0 (April 11, 2013)
----------------------

* Accept an array of symbols for the scope attribute to scope by multiple
  columns.

1.1.0 (July 5, 2012)
--------------------

* Raise ArgumentError instead of Sequenced::InvalidAttributeError
* Remove custom exceptions
* Stop calling it a "plugin"

1.0.0 (March 7, 2012)
---------------------

* Restrict dependencies on ActiveSupport and ActiveRecord to `~> 3.0`
* Make error messages more descriptive
* Update gem description


0.1.0 (February 19, 2012)
-------------------------

* Initial release
