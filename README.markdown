# SimpleCMS
## Dependencies
### Ruby Gems
Running `bundle install` should be able to download and install all Ruby Gems dependencies.

### PostgreSQL
This app is using PostgreSQL. Hence, it is necessary to have PostgreSQL running. The database configurations for production and test environments should be defined in the following environment variables:

- `PG_USERNAME`
- `PG_PASSWORD`
- `PG_SIMPLECMS_DEV`
- `PG_SIMPLECMS_TEST`

### Redis

## Running background worker
`bundle exec sidekiq`

## Running Tests
Run `bundle exec rake` to run all tests.

## Deployment
See SERVER_SETUP for more information on setting up a production server.

After the initial setup, each deployment (updates):
```bash
# Kill existing Thin and Sidekiq processes
bundle exec rake assets:precompile
bundle exec rake assets:clean
bundle exec rake db:migrate
bundle exec sidekiq -e production &
bundle exec thin start -e production &
```

## Development
### `data-` attributes
#### `data-mathjax-source`
Attaching this attribute to an element will cause MathJax to typeset the content of the element.
