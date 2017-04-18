# -*- encoding: utf-8 -*-
#

require 'yaml'
require 'admiral/layer'

module Admiral
  module Layers
    class AdmiralPuppetApply < Admiral::LayerBase
      def initialize(config, ipaddress)
        description = "Applying cookbooks"

        super(description, config, ipaddress)
      end

      def do_action

        manifest      = @config['manifest']
        manifests_dir = '/var/lib/puppet/manifests'
        modules_dir   = '/var/lib/puppet/modules'

        cmd = "puppet apply --verbose --modulepath=#{modules_dir} #{manifests_dir}/#{manifest}"

        rc = run_ssh_command(cmd, :allow_proxy => false)
        return (rc == 0)
      end
    end
  end
end

