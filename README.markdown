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

## Environment Variables

- `PG_USERNAME`
- `PG_PASSWORD`
- `PG_SIMPLECMS_DEV`
- `PG_SIMPLECMS_TEST`
- `NEW_RELIC_LICENSE_KEY`
- `PUSHBULLET_ACCESS_TOKEN`
- `GA_TRACKING_ID`
- `CONTACT_EMAIL`

## Development
### `data-` attributes
#### `data-mathjax-source`
Attaching this attribute to an element will cause MathJax to typeset the content of the element.

## Input generator and grader
Each task should have an input generator and a grader.
### Input generator
Input generator should implement the `generate_input` method which takes in a seed, and output an array of hashes. The keys to each hash should be the name of a variable, and the values are the values of each variable. Hashes that appear earlier in the output array will be present to the user first. It is important that `generate_input` will always output the same thing given the same seed. Hence, to randomize the test cases, you may use the `Random` standard library. An example of a valid input generator:

```ruby
# Problem statement:
# Given an array of N positive integers, output the K-th smallest number in that array.
def generate_input(seed)
  prng = Random.new(seed)
  n = 1000
  k = prng.rand(n) + 1
  numbers = (1..n).to_a.map { prng.rand(10000) }

  # In this case, it is guaranteed that N and K will be presented to the user first follow by numbers
  [{N: n, K: k}, {numbers: numbers}]
end
```

### Grader
Grader should implement the `grade_answer` method which takes in the output of input generator and a string provided by the user (which is the answer to be judged), and output either `true` or `false`. An example of a valid grader:

```ruby
def grade_answer(input, answer)
  # Answer must represent an integer
  return false unless answer.strip =~ /\A\d+\z/

  input[1][:numbers].sort[input[0][:K] - 1] == answer.to_i
end
```
