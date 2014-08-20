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
RAILS_ENV=production bundle exec thin --environment production --daemonize restart
