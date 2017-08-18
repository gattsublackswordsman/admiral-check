# -*- encoding: utf-8 -*-
#

require 'yaml'
require 'admiral/layer'

module Admiral
  module Layers
    class AdmiralTestServerspecInstall < Admiral::LayerBase
      def initialize(config, ipaddress)
        description = "Install serverspec and infraspec"

        super(description, config, ipaddress)
      end

      def do_action()
        username  = @config['username']

        gemsdir   = "/tmp/#{username}/gems"
        cachedir  = "#{gemsdir}/cache"

        env = {
          'username'  => username,
          'GEM_HOME'  => gemsdir,
          'GEM_PATH'  => gemsdir,
          'GEM_CACHE' => cachedir,
        }

        cmd = "#{@workdir}/#{$uid}.sh"

        rc = run_ssh_command(cmd, :allow_proxy => true, :env => env)
        return (rc == 0)
      end
    end
  end
end

