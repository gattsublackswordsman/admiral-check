# -*- encoding: utf-8 -*-
#

require 'yaml'
require 'admiral/layer'
require 'admiral/shell'

module Admiral
  class Layer < Admiral::LayerBase
    def initialize(config, ipaddress)
      description = "Retrieving cookbooks for applications from SVN "

      super(description, config, ipaddress)   
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
        cmd = "svn co --non-interactive --no-auth-cache  #{svn_cookbook_base_url}/#{application_code}/#{application_branch}/ #{modules_dir}/#{application_code}  --username=#{svn_user} --password=#{svn_password}; done"
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

