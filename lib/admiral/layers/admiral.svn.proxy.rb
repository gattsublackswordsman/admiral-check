# -*- encoding: utf-8 -*-
#

require 'yaml'
require 'admiral/layer'

module Admiral
  module Layers
    class AdmiralSvnProxy < Admiral::LayerBase
      def initialize(config, ipaddress)
        description = "Configuring proxy for SVN"

        super(description, config, ipaddress)
        add_parameter('svn_proxy_host', 'Hostname of the proxy needed to access to svn (ex: proxy.domain.com )')
        add_parameter('svn_proxy_port', 'Port of the proxy (ex: 80)')
        add_parameter('svn_proxy_user', 'Username for the proxy (ex: user)')
        add_parameter('svn_proxy_password', 'Password for the proxy (ex: passwd)')
      end

      def do_action
        svn_proxy_host      = @config['svn_proxy_host']
        svn_proxy_port      = @config['svn_proxy_port']
        svn_proxy_user      = @config['svn_proxy_user']
        svn_proxy_password  = @config['svn_proxy_password']
        username            = @config['username']

        env = {
          'svn_proxy_host'     => svn_proxy_host,
          'svn_proxy_port'     => svn_proxy_port,
          'svn_proxy_user'     => svn_proxy_user,
          'svn_proxy_password' => svn_proxy_password,
        }

        cmd = "/tmp/#{username}/#{$uid}.sh"

        rc = run_ssh_command(cmd, :env => env)
        return (rc == 0)
      end
    end
  end
end

