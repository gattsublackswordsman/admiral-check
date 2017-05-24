# -*- encoding: utf-8 -*-
#

require 'yaml'
require 'admiral/layer'

module Admiral
  module Layers
    class AdmiralSvnPuppetManifest < Admiral::LayerBase
      def initialize(config, ipaddress)
        description = "Retrieving manifest from SVN"

        super(description, config, ipaddress)
        add_parameter('svn_manifest_base_url', 'Root URL where are located the manifests in SVN (ex: https://domain.com/puppet-manifests)')
        add_parameter('manifest_source', 'Path after the root URL (ex: production)')
        add_parameter('svn_user', 'Username for SVN')
        add_parameter('svn_password', 'Passsword for SVN')
      end

      def do_action
        manifest_source       = @config['manifest_source']
        manifests_dir         = '/var/lib/puppet/manifests'
        svn_manifest_base_url = @config['svn_manifest_base_url']
        svn_user              = @config['svn_user']
        svn_password          = @config['svn_password']

        cmd = "svn co --non-interactive --no-auth-cache #{svn_manifest_base_url}/#{manifest_source} #{manifests_dir}  --username=#{svn_user} --password=#{svn_password}"

        rc = run_ssh_command(cmd)
        return (rc == 0)
      end
    end
  end
end

