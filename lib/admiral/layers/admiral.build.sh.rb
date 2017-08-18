# -*- encoding: utf-8 -*-
#

require 'yaml'
require 'admiral/layer'

module Admiral
  module Layers
    class AdmiralBuildSh < Admiral::LayerBase
      def initialize(config, ipaddress)
        description = "Executing build script"

        super(description, config, ipaddress)
        add_parameter('build_script', 'Script file for build (ex: bootstap.sh)')
        add_parameter('build_env', 'Hash of environmental variables (ex: {"param1"=>"value1", "param2"=>"value2"} )')
      end

      def do_action()
        username     = @config['username']
        build_script = @config['build_script']
        build_env    = @config['build_env']

        if not File.exists?(build_script)
          STDERR.puts "File #{build_script} not found"
          return false
        end

        upload(build_script, @workdir)

        cmd = %Q[bash #{@workdir}/#{build_script}]

        rc = run_ssh_command(cmd, :env => build_env)
        return (rc == 0)
      end
    end
  end
end

