# -*- encoding: utf-8 -*-
#

require 'yaml'
require 'admiral/layer'

module Admiral
  class Layer < Admiral::LayerBase
    def initialize(config, ipaddress)
      description = "Install serverspec and infraspec"

      super(description, config, ipaddress)
    end

    def do_action()
      username  = @config['username']

      gemsdir   = "/tmp/#{username}/gems"
      cachedir  = "#{gemsdir}/cache"

      cmd = "mkdir -p #{cachedir};"
      cmd << %Q[GEM_HOME="#{gemsdir}" GEM_PATH="#{gemsdir}" GEM_CACHE="#{cachedir}";]
      cmd << %Q[export GEM_HOME GEM_PATH GEM_CACHE;]
      cmd << %Q[/opt/chef/embedded/bin/gem install serverspec specinfra --no-rdoc --no-ri;]
      cmd << %Q[chown #{username}:#{username} -R /tmp/#{username}]

      rc = run_ssh_command(cmd, :allow_proxy => true)
      return (rc == 0)
    end
  end
end

