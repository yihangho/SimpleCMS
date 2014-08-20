#!/bin/bash

DEPLOYMENT_DIR="$HOME/SimpleCMSDeployment"

read oldrev newrev refname

if ! [[ "$refname" =~ master$ ]]; then
  exit 0
fi

source $HOME/.rvm/scripts/rvm

GIT_WORK_TREE=$DEPLOYMENT_DIR git checkout -f master

cd $DEPLOYMENT_DIR

script/server_update.sh
