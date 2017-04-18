#! /bin/sh

mkdir -p "${GEM_CACHE}"
export GEM_HOME GEM_PATH GEM_CACHE
/opt/chef/embedded/bin/gem install serverspec specinfra --no-rdoc --no-ri
chown ${username}:${username} -R /tmp/${username}
