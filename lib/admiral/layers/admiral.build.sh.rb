# -*- encoding: utf-8 -*-
#

require 'yaml'
require 'admiral/layer'

module Admiral
  module Layers
    class AdmiralBuild < Admiral::LayerBase
      def initialize(config, ipaddress)
        description = "Executing build script"

        parameters = ['build_script', 'build_env']
        super(description, config, ipaddress, parameters)
      end

      def do_action()
        username     = @config['username']
        build_script = @config['build_script']
        build_env    = @config['build_env']

        work_dir = "/tmp/#{username}/"

        if not File.exists?(build_script)
          STDERR.puts "File #{build_script} not found"
          return false
        end

        upload(build_script, work_dir)

        cmd = %Q[bash /tmp/#{username}/#{build_script}]

        rc = run_ssh_command(cmd, :env => build_env)
        return (rc == 0)
      end
    end
  end
end

