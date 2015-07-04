#!/bin/bash

# Bootstrap a fresh copy of Ubuntu 14.04.1 Server to run SimpleCMS

DEPLOYMENT_DIR="$HOME/SimpleCMSDeployment"

echo "Upgrading your system"
sudo add-apt-repository ppa:rwky/redis
sudo apt-get -y update
sudo apt-get -y upgrade

echo "Installing system dependencies"
sudo apt-get -y install git-core postgresql libpq-dev nodejs openssh-server nginx redis-server

echo "Installing RVM"
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm

echo "Installing Ruby 2.1.2"
rvm install 2.1.2

echo "Setting Ruby 2.1.2 as default Ruby"
rvm --default use 2.1.2

echo "Setting up PostgreSQL"
echo "You have to pick a password for the PostgreSQL user."
echo "You only have to remember this password until the end of the installation process, so pick a strong one."
sudo su postgres -c "createuser simplecms -P"
sudo su postgres -c "createdb -O simplecms simplecms_production"
sudo su postgres -c "psql simplecms_production -c 'ALTER SCHEMA public OWNER TO simplecms'"
sudo su postgres -c "echo 'local all all md5' >> /etc/postgresql/9.3/main/pg_hba.conf"
sudo service postgresql restart

echo "Getting SimpleCMS source"
cd $HOME
git clone https://github.com/yihangho/SimpleCMS.git --bare
cd SimpleCMS.git
mkdir -p $DEPLOYMENT_DIR
GIT_WORK_TREE=$DEPLOYMENT_DIR git checkout -f mcc2015
cd $DEPLOYMENT_DIR

echo "Installing Ruby Gems"
bundle install --without development:test

read -sp "Enter the PostgreSQL password: " pg_password; echo

echo "Setting environment variables"
echo "export PG_USERNAME=simplecms" >> ~/.profile
echo "export PG_PASSWORD='$pg_password'" >> ~/.profile
echo "export PG_SIMPLECMS_PROD=simplecms_production" >> ~/.profile
echo "export SECRET_KEY_BASE=`bundle exec rake secret`" >> ~/.profile
echo "export DEPLOYMENT_DIR=$DEPLOYMENT_DIR" >> ~/.profile
source ~/.profile

echo "Installing Git post-receive hook"
cp script/post-receive.sh $HOME/SimpleCMS.git/hooks/post-receive

echo "Setting up Nginx"
read -p "Enter the server name (an IP or domain): " server_name; echo
sed -e "s|<SERVER_NAME_PLACEHOLDER>|$server_name|" -e "s|<SERVER_ROOT_PLACEHOLDER>|$DEPLOYMENT_DIR/public|" config/nginx_default > /tmp/nginx_default
sudo mv /tmp/nginx_default /etc/nginx/sites-available/default
sudo ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
sudo service nginx restart

echo "Setting up database"
RAILS_ENV=production bundle exec rake db:schema:load

echo "Precompiling assets"
RAILS_ENV=production bundle exec rake assets:precompile

echo "Starting Thin"
RAILS_ENV=production bundle exec thin --config config/thin.yml start

echo "Setting up database dumping"
mkdir dump
crontab script/crontab.txt
