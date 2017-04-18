# -*- encoding: utf-8 -*-
#

require 'yaml'
require 'admiral/layer'

module Admiral
  module Layers
    class AdmiralTestChefInstall < Admiral::LayerBase
      def initialize(config, ipaddress)
        description = "Get and install chef"

        super(description, config, ipaddress)
      end

      def do_action()

        cmd = 'wget --no-check-certificate https://www.chef.io/chef/install.sh -O /tmp/install.sh && /bin/bash /tmp/install.sh'

        rc = run_ssh_command(cmd, :allow_proxy => true)
        return (rc == 0)
      end
    end
  end
end

