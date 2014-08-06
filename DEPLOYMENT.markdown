# Deployment
This guide is tested on a clean copy of Ubuntu Server 14.04.1.

## System Update
```bash
sudo apt-get update
sudo apt-get upgrade
```

## System Dependencies
```bash
sudo apt-get install git-core postgresql redis-server libpq-dev nodejs
```

## Ruby
```bash
\curl -sSL https://get.rvm.io | bash -s stable
rvm install 2.1.2 # RVM will also install a bunch of other necessary system tools
```

## PostgreSQL Setup
```bash
sudo su - postgres
createuser simplecms -P
createdb -O simplecms simplecms_production
psql simplecms_production -c 'ALTER SCHEMA public OWNER TO simplecms'
vim /etc/postgresql/9.3/main/pg_hba.conf
# Look for the line 'local all all peer' and change it to 'local all all md5'
exit
sudo service postgresql restart
vim .bash_profile # Set PG_USERNAME, PG_PASSWORD, PG_SIMPLECMS_PROD
source .bash_profile
```

## Source
```bash
git clone https://yihangho@bitbucket.org/yihangho/simple-cms.git
```

## Ruby Gems
```bash
cd simple-cms
git checkout sidekiq-bg-worker
bundle
RAILS_ENV=production bundle exec rake db:schema:load
bundle exec thin start -e production
bundle exec sidekiq -e production
```
