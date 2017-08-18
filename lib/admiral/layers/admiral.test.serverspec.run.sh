#! /bin/sh

export GEM_HOME GEM_PATH GEM_CACHE
cd ${workdir}
/opt/chef/embedded/bin/rake
