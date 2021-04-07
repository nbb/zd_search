# Zendesk Search

See `discussion.md` for discussion of assumptions and tradeoffs.

## Description

Zendesk Search is a simple command line application for indexing and searching provided json data files.

Zendesk Search allows a user to search across the 3 entities provided in data files: 'Organizations', 'Tickets' and 'Users'. For each of these entities, a user can search a particular field, for example 'name' in 'Users'. The application provides further usage instructions and help when executed.

The search supports:
* searching by keyword, e.g. searching user names for 'Rasmussen' will return a record with the name 'Francisca Rasmussen'.
* searching boolean fields by typing 'true' or 'false'.
* searching nested arrays, e.g. a user that has multiple tags can be searched by any one of those tags.

Please note that all search is case-insensitive.

## Requirements

Zendesk search was coded using Ruby version 3.0.1, but it has also been tested as working with Ruby 2.7.3.

Zendesk Search will index three JSON files when executed, allowing them to then be searched. These 3 files are `organizations.json`, `tickets.json` and `users.json` and they need to reside in the `\data` directory. This project comes with 3 example files.

## Running the application

Once you have Ruby installed, run the application with the following command:

```
ruby ./zendesk_search.rb
```

Follow the on screen instructions and type `\help` at anytime to see a list of commands

## Running the tests

Install `bundler` if needed, then bundle the `rspec` gem dependency by running:

```
bundle install
```

To run all the specs, run the following command:

```
bundle exec rspec
```
