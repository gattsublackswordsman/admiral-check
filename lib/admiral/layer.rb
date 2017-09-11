# -*- encoding: utf-8 -*-
#

require 'yaml'
require 'admiral/config'
require 'net/ssh'
require 'net/scp'
require 'pp'

module Admiral

  module Layer
    def self.uid_to_name(uid)
      class_name = ''

      l = uid.split('.')
      l.each do |word|
        class_name <<  word.capitalize
      end

      return class_name
    end
  end

  class LayerBase

    def self.inherited(subclass)
      file = caller.first[/^[^:]+/]
      $uid = File.basename(file,File.extname(file))
      $location = File.dirname(file)
    end

    def initialize(description, config, ipaddress)
      @description = description
      @config = config
      @ipaddress = ipaddress
      @mandatory_parameters = []
      @optional_parameters  = []
      @workdir = "/tmp/#{@config['username']}/#{$uid}.d" if not config.nil?
    end

    def add_parameter(name, description)
       parameter = { 'name'=>name, 'description'=>description }
       @mandatory_parameters << parameter
    end

    def add_optional_parameter(name, description)
       parameter = { 'name'=>name, 'description'=>description }
       @optional_parameters << parameter
    end

    def set_workdir(workdir)
       if not @config.nil?
         username = @config['username']
         @workdir = "/tmp/#{username}/#{workdir}/"
       end
    end

    def show_information
       puts "Layer UID:   #{$uid}"
       puts "Description: #{@description}"

       if @mandatory_parameters.count > 0
         puts "Mandatory parameters :"
         @mandatory_parameters.each do | parameter |
           puts "  #{parameter['name']} / #{parameter['description']}"
         end
       end

       if @optional_parameters.count > 0
         puts "Optional parameters :"
         @optional_parameters.each do | parameter |
           puts "  #{parameter['name']} / #{parameter['description']}"
         end
       end

       if not @mandatory_parameters.count > 0 and not @optional_parameters.count > 0
         puts "No paramater"
       end

    end

    def verify ()
      @mandatory_parameters.each do | parameter |
        if not  @config.key?(parameter['name'])
          STDERR.puts "Layer #{$uid} requires the parameter #{parameter['name']}, but it is not found"
          return false
        end
      end
      return true
    end

    def run()
      puts "--- #{@description} ---"
      username = @config['username']

      layer_location   = $location
      layer_uid        = $uid

      layer_folder     = "#{layer_location}/#{layer_uid}.d"
      layer_shell      = "#{layer_location}/#{layer_uid}.sh"
      layer_perl       = "#{layer_location}/#{layer_uid}.pl"
      layer_remote_dir = @workdir

      begin

        run_ssh_command("install -d -o #{username} -g #{username} #{@workdir}")

        if File.exists?(layer_folder)
          upload("#{layer_folder}/.",  layer_remote_dir)
        end

        if File.exists?(layer_shell)
          upload(layer_shell, layer_remote_dir)
        end

        if File.exists?(layer_perl)
          upload(layer_perl, layer_remote_dir)
        end

        success = do_action()
      rescue Interrupt
        STDERR.puts "Layer interrupted"
        return false
      rescue Errno::EACCES, Errno::ENOENT, Errno::ECONNREFUSED, IOError => e
        STDERR.puts "Layer has error : #{e.message}"
        return false
      rescue Net::SSH::AuthenticationFailed
        STDERR.puts "Layer has error : SSH - Authentication failed"
        return false
      end

      return success
    end

    def do_action()
      STDERR.puts "do_action must be implemented"
      return false
    end

    def run_ssh_command(command, options = {})
      username = @config['username']
      keyfile = @config['keyfile']
      proxy_url = @config['proxy_url']
      allow_proxy = options.fetch(:allow_proxy, false)
      env = options.fetch(:env, nil)

      env_array = []
      cmd = ""

      if allow_proxy and  proxy_url
        cmd << %Q[export http_proxy="#{proxy_url}";]
        cmd << %Q[export https_proxy=$http_proxy;]
      end

      cmd << command

      ssh_cmd = ""

      if not env.nil?
        env.each do |key, value|
          ENV[key] = value
          env_array << key
        end
      end

      ssh_cmd << "sudo -E sh -c '#{cmd}'"

      Net::SSH.start(@ipaddress, username, :host_key => "ssh-rsa", :keys => [ keyfile ], :user_known_hosts_file => '/dev/null', :send_env => env_array) do |ssh|

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
                STDERR.puts "FAILED: command (#{command}) has failed"
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
