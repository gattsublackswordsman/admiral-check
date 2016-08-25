# -*- encoding: utf-8 -*-
#

require 'yaml'
require 'admiral/layer'

module Admiral
  class Layer < Admiral::LayerBase
    def initialize(config, ipaddress)
      description = "Upload serverspec tests"

      super(description, config, ipaddress)
    end

    def do_action()

      remote_test_dir = "/tmp/#{username}/test"
      remote_spec_dir = "/tmp/#{username}/test/spec"

      dirname = File.dirname(__FILE__)
      uid = File.basename(__FILE__,File.extname(__FILE__))

      local_test_dir = "#{dirname}/#{uid}.d"
      local_spec_dir = "test"

      upload(local_test_dir, remote_test_dir)
      upload(local_spec_dir, remote_spec_dir)

      return true
    end
  end
end

