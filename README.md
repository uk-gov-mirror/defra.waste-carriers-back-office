# Entity Matching Service

A simple web service that allows other apps to query if a specified entity matches against a list of known entities.

The service is queried via a web API, and returns the result as JSON.

It was created when it was found more than one app needed to query the same list of entities. So it was decided to move the functionality to a separate web app that would manage loading, maintaining and querying the datasets those applications want to match against.

## Prequisites

You'll need [Ruby 2.4.2](https://www.ruby-lang.org/en/) installed plus the [Bundler](http://bundler.io/) gem.

## Installation

First clone the repository and then drop into your new local repo

```bash
git clone https://gitlab-dev.aws-int.defra.cloud/waste-carriers/entity-matching-service.git && cd entity-matching-service
```

Next download and install the dependencies

```bash
bundle install
```

## Configuration

Any configuration is expected to be driven by environment variables when the service is run in production as per [12 factor app](https://12factor.net/config).

However when running locally in development mode or in test it makes use of the [Dotenv](https://github.com/bkeepers/dotenv) gem. This is a shim that will load values stored in a `.env` file into the environment which the service will then pick up as though they were there all along.

Check out [.env.example](/.env.example) for details of what you need in your `.env` file, and what environment variables you'll need in production.

## Running the app

Simply start the app using `bundle exec rails s`. If you are in an environment with other Rails apps running you might find the default port of 3000 is in use and so get an error.

If that's the case use `bundle exec rails s -p 3010` swapping `3010` for whatever port you want to use.

## Testing the app

The test suite is written in RSpec.

To run all the tests, use `bundle exec rspec`

## Contributing to this project

If you have an idea you'd like to contribute please log an issue.

All contributions should be submitted via a pull request.

## License

THIS INFORMATION IS LICENSED UNDER THE CONDITIONS OF THE OPEN GOVERNMENT LICENCE found at:

http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

The following attribution statement MUST be cited in your products and applications when using this information.

> Contains public sector information licensed under the Open Government license v3

### About the license

The Open Government Licence (OGL) was developed by the Controller of Her Majesty's Stationery Office (HMSO) to enable information providers in the public sector to license the use and re-use of their information under a common open licence.

It is designed to encourage use and re-use of information freely and flexibly, with only a few conditions.
