# -*- encoding: utf-8 -*-
#

require 'yaml'
require 'admiral/layer'

module Admiral
  class Layer < Admiral::LayerBase
    def initialize(config, ipaddress)
      description = "Run RSpec "

      super(description, config, ipaddress)
    end

    def do_action()
      username  = @config['username']

      gemsdir   = "/tmp/#{username}/gems"
      cachedir  = "#{gemsdir}/cache"

      cmd = %Q[GEM_HOME="#{gemsdir}" GEM_PATH="#{gemsdir}" GEM_CACHE="#{cachedir}";]
      cmd << %Q[export GEM_HOME GEM_PATH GEM_CACHE;]
      cmd << %Q[cd /tmp/#{username}/test;]
      cmd << %Q[/opt/chef/embedded/bin/rake]

      rc = run_ssh_command(cmd)
      return (rc == 0)
    end
  end
end

