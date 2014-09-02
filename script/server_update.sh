#!/bin/bash

# This script can be run to perform necessary action to deploy newest version in DEPLOYMENT_DIR

source $HOME/.profile

DEPLOYMENT_DIR="$HOME/SimpleCMSDeployment"

cd $DEPLOYMENT_DIR

echo "Updating Ruby Gems"
bundle

echo "Migrating database"
RAILS_ENV=production bundle exec rake db:migrate

echo "Precompiling assets"
RAILS_ENV=production bundle exec rake assets:precompile
RAILS_ENV=production bundle exec rake assets:clean

echo "Restart server"
if [[ -f tmp/pids/thin.0.pid ]]; then
  RAILS_ENV=production bundle exec thin --config config/thin.yml restart
else
  RAILS_ENV=production bundle exec thin --config config/thin.yml start
fi
