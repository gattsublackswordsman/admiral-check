# -*- encoding: utf-8 -*-
#

require 'yaml'
require 'admiral/layer'

module Admiral
  module Layers
    class AdmiralTestServerspecRun < Admiral::LayerBase
      def initialize(config, ipaddress)
        description = "Run RSpec"

        super(description, config, ipaddress)
        set_workdir("admiral.test.serverspec.d")
      end

      def do_action()
        username  = @config['username']

        gemsdir   = "/tmp/#{username}/gems"
        cachedir  = "#{gemsdir}/cache"

        env = {
          'username'  => username,
          'workdir'   => @workdir,
          'GEM_HOME'  => gemsdir,
          'GEM_PATH'  => gemsdir,
          'GEM_CACHE' => cachedir,
        }

        cmd = "#{@workdir}/#{$uid}.sh"

        rc = run_ssh_command(cmd, :env => env)
        return (rc == 0)
      end
    end
  end
end

