# -*- encoding: utf-8 -*-
#

require 'yaml'
require 'admiral/layer'

module Admiral
  class Layer < Admiral::LayerBase
    def initialize(config, ipaddress)
      description = "A simple test"

      super(description, config, ipaddress)
    end

    def do_action()
      cmd = "touch /tmp/simple-test"
      run_ssh_command(cmd)

      return true
    end

  end
end

