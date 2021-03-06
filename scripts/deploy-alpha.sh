#!/bin/sh

# Before running this script you must have installed the AWS CLI.
# On ubuntu, do:
# 1) sudo apt-get install python-pip python-dev build-essential 
# 2) pip install --upgrade --user awscli
# 3) Set up the AWS credentials using aws configure

if [ "$#" -ne 1 ];
  then echo "Wrong number of arguments"
       echo "Please provide a single argument specifying the branch to deploy"
       exit 1;
fi

cd /vagrant
mkdir live
cd live
git clone -b $1 git@github.com:genderkit/genderkit.git
cd genderkit
tmpfile=`mktemp --suffix=.yml`
echo "css_ver:" $(tr -cd 0-9 </dev/urandom | head -c 6) > $tmpfile
bundle install
bundle add jekyll-sitemap
bundle exec rake resize
bundle exec jekyll build --config /vagrant/live/genderkit/_config-alpha.yml,$tmpfile
bundle exec rake referencelinks
aws s3 sync ./_site/ s3://alpha.genderkit.org.uk/ --metadata-directive REPLACE --cache-control max-age=86400
rm -rv /vagrant/live
