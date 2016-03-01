# RabbitCI

This is RabbitCI.

RabbitCI is a Continuous Integration server. It is currently in pre-alpha
stage. It would help if you would write some code. Look at the issues page for
things to do.

## Dependencies
The backend depends on:

- Elixir
- Postgres
  - Dev/Test: username: postgres, password: postgres, databases: rabbitci_test,
    rabbitci_dev. User can be created by running `CREATE USER postgres SUPERUSER
    PASSWORD 'postgres';` in `psql postgres`. Never do this in
    production. Databases will be automatically created by the Makefile.
- RabbitMQ
- Vagrant
- Git

## Getting started

### OS X

Install homebrew then run `make setup_osx`.

Then, in `psql postgres`, run `CREATE USER postgres SUPERUSER PASSWORD
'postgres';` (`\q` to exit). **This is horribly insecure. Do not use this for
anything other than development. Be careful if you have ports open. You have
been warned.**

NOTE: This will start PostgreSQL and RabbitMQ using `brew services`.
