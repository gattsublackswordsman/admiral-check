#! /bin/sh

mkdir -p "${GEM_CACHE}"
export GEM_HOME GEM_PATH GEM_CACHE
/opt/chef/embedded/bin/gem install serverspec specinfra rake --no-rdoc --no-ri
