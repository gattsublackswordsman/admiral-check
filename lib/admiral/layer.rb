# -*- encoding: utf-8 -*-
#

require 'yaml'
require 'admiral/config'
require 'net/ssh'
require 'net/scp'

module Admiral
  class LayerBase

    def initialize(description, config, ipaddress)
      @description = description
      @config = config
      @ipaddress = ipaddress
    end

    def run()
      puts "--- #{@description} ---"
      success = do_action()
      return success
    end

    def do_action()
      STDERR.puts "do_action must be implemented"
      exit!
    end

    def run_ssh_command(command, options = {})
      username = @config['username']
      keyfile = @config['keyfile']
      proxy_url = @config['proxy_url']
      allow_proxy = options.fetch(:allow_proxy, false)
      env = options.fetch(:env, nil)

      cmd = ""

      if allow_proxy and  proxy_url
        cmd << %Q[export http_proxy="#{proxy_url}";]
        cmd << %Q[export https_proxy=$http_proxy;]
      end

      cmd << command

      ssh_cmd = ""

      if not env.nil?
        env.each do |key, value|
          ssh_cmd << %Q[#{key}="#{value}" ]
        end
      end

      ssh_cmd << "sudo -E sh -c '#{cmd}'"

      Net::SSH.start(@ipaddress, username, :host_key => "ssh-rsa", :keys => [ keyfile ], :user_known_hosts_file => '/dev/null') do |ssh|

        ssh.open_channel do |channel|
          channel.exec(ssh_cmd) do |ch, success|
            unless success
              STDERR.puts "FAILED: couldn't execute command (#{command})"
              return false
            end


            channel.on_data do |ch, data|
              puts data
            end

            channel.on_extended_data do |ch, type, data|
              STDERR.puts data
            end

            channel.on_request("exit-status") do |ch,data|
              exit_code = data.read_long
              if exit_code > 0
                STDERR.puts "FAILED: command (#{command}) has failure"
                return exit_code
              end
            end
          end
        end

        ssh.loop
        return 0
      end
    end

    def upload(local, remote)

      username = @config['username']
      keyfile = @config['keyfile']

      Net::SCP.upload!(@ipaddress, username,
      local, remote,
      :recursive => true,
      :ssh => { :host_key => "ssh-rsa", :keys => [ keyfile ], :user_known_hosts_file => '/dev/null' })

    end
  end
end
