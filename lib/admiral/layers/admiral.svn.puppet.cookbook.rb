# -*- encoding: utf-8 -*-
#

require 'yaml'
require 'admiral/layer'
require 'admiral/shell'

module Admiral
  module Layers
    class AdmiralSvnPuppetCookbook < Admiral::LayerBase
      def initialize(config, ipaddress)
        description = "Retrieving cookbooks for applications from SVN"

        super(description, config, ipaddress)
        add_parameter('svn_cookbook_base_url', 'Root URL where are located the cookbooks in SVN (ex: https://domain.com/puppet-cookbooks)')
        add_parameter('svn_user', 'Username for SVN')
        add_parameter('svn_password', 'Password for SVN')
        add_parameter('applications', 'List of hash that contains application code and source branch (ex: [ {"code"=>"appli1", "branch"=>"trunk"}, ]  )', :type => Array )
      end

      def do_action
        svn_cookbook_base_url = @config['svn_cookbook_base_url']
        svn_user              = @config['svn_user']
        svn_password          = @config['svn_password']

        modules_dir           = '/var/lib/puppet/modules/'

        applications          = @config['applications']

        applications.each do | application |
          application_code   = application['code']
          application_branch = application['branch']
          cmd = "svn co --non-interactive --no-auth-cache  #{svn_cookbook_base_url}/#{application_code}/#{application_branch}/ #{modules_dir}/#{application_code}  --username=#{svn_user} --password=#{svn_password}"
          puts " - Retrieving cookbook for project #{application_code} from #{application_branch}"

          rc = run_ssh_command(cmd)
          if rc > 0
            return false
          end
        end

        return true
      end
    end
  end
end

