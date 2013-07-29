Key/Value Store in Ruby
=======================

Simple key/value database in Ruby with transaction support.

This program requires only on Ruby 1.9.3. Run it as follows:

    ./run

You have to following commands:

* SET [name] [value]
* GET [name]
* UNSET [name]
* NUMEQUALTO [value]
* BEGIN -- begin a transaction, nesting is permitted
* ROLLBACK -- rollback the most recent transaction
* COMMIT -- commit all transactions
* END -- exit

For more usage details see the spec file.

To run the specs, you'll have to install the rspec gems first:

    bundle install
    rspec spec/command_spec.rb

