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
      end

      def do_action()
        username  = @config['username']

        remote_test_dir = "/tmp/#{username}/test"
        remote_spec_dir = "/tmp/#{username}/test/spec"

        local_test_dir = "#{$location}/#{$uid}.d"
        local_spec_dir = "test"

        upload(local_test_dir, remote_test_dir)
        upload(local_spec_dir, remote_spec_dir)

        return true
      end
    end
  end
end

