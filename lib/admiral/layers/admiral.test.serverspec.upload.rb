# -*- encoding: utf-8 -*-
#

require 'yaml'
require 'admiral/layer'

module Admiral
  module Layers
    class AdmiralTestServerspecUpload < Admiral::LayerBase
      def initialize(config, ipaddress)
        description = "Upload serverspec tests"

        super(description, config, ipaddress)
        set_workdir("admiral.test.serverspec.d")
      end

      def do_action()
        username  = @config['username']

        remote_spec_dir = "#{@workdir}/spec"
        local_spec_dir  = "test"

        if not Dir.exists?(testdir)
          STDERR.puts "Test directory not found"
          return false
        end

        upload(local_spec_dir, remote_spec_dir)
        return true
      end
    end
  end
end

