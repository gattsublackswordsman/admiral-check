# -*- encoding: utf-8 -*-
#

require 'yaml'
require 'admiral/layer'

module Admiral
  class Layer < Admiral::LayerBase
    def initialize(config, ipaddress)
      description = "Configuring proxy for SVN"

      super(description, config, ipaddress)
    end

    def do_action
      svn_proxy_host      = @config['svn_proxy_host']
      svn_proxy_port      = @config['svn_proxy_port']
      svn_proxy_user      = @config['svn_proxy_user']
      svn_proxy_password  = @config['svn_proxy_password']

      cmd = ""
      cmd << %Q(echo "http-proxy-host = #{svn_proxy_host}" >> /etc/subversion/servers;)
      cmd << %Q(echo "http-proxy-port = #{svn_proxy_port}" >> /etc/subversion/servers;)
      cmd << %Q(echo "http-proxy-username = #{svn_proxy_user}" >> /etc/subversion/servers;)
      cmd << %Q(echo "http-proxy-password = #{svn_proxy_password}" >> /etc/subversion/servers;)

      rc = run_ssh_command(cmd)
      return (rc == 0)
    end
  end
end

