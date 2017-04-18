#! /bin/sh

export GEM_HOME GEM_PATH GEM_CACHE
cd /tmp/${username}/test
/opt/chef/embedded/bin/rake
