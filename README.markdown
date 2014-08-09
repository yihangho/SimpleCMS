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
- `STORAGE_TYPE`
- `AWS_ID`
- `AWS_SECRET_KEY`
- `SIMPLECMS_INPUT`
- `SIMPLECMS_OUTPUT`
- `SIMPLECMS_SUBMISSION`

## Running Tests
Run `bundle exec rake` to run all tests.

## Deployment
This app has been deployed to Heroku. A simple `git push heroku master` should do the job. You might also need to run `heroku run rake db:schema:load` after the very first deployment, or `heroku run rake db:migrate` after an update.

## Development
### `data-` attributes
#### `data-mathjax-source`
Attaching this attribute to an element will cause MathJax to typeset the content of the element.
