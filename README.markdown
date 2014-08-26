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

### Qt
We are using `capybara-webkit` to run our integration tests. This gem depends on Qt. For more info on installing Qt, [read this](https://github.com/thoughtbot/capybara-webkit/wiki/Installing-Qt-and-compiling-capybara-webkit).

## Running Tests
Run `bundle exec rake` to run all tests.

## Deployment
### Heroku
A simple `git push heroku master` should do the job. You might also need to run `heroku run rake db:schema:load` after the very first deployment, or `heroku run rake db:migrate` after an update.

### Ubuntu
This method is tested on Ubuntu Server 14.04.1. Run

```bash
source <(curl -sS https://raw.githubusercontent.com/yihangho/SimpleCMS/master/script/server_bootstrap.sh)
```

to bootstrap the server. On your development repository, run

```bash
git add remote production <username>@<host>:SimpleCMS.git
```

Replace `<username>` with the user on the server that ran the setup script and `<host>` with the IP/domain of the server. To deploy, just push to the `master` branch of `production` remote.

## Development
### `data-` attributes
#### `data-mathjax-source`
Attaching this attribute to an element will cause MathJax to typeset the content of the element.
