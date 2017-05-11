# -*- encoding: utf-8 -*-
#

require 'admiral/config'
require 'admiral/shell'
require 'admiral/layer'

module Admiral
  module Docker

    def self.create (platform)

      platform_name = platform['name']
      image         = platform['image']
      docker        = platform['docker']
      hostname      = platform['hostname']
      ssh_key_file  = platform['keyfile']
      username      = platform['username']
      password      = platform['password']
      volumes       = platform['volumes']

      last_container_id = get_container_id(platform_name)
      if last_container_id
        puts "Container exist : #{last_container_id}"
      else
        dockerfile = generate_dockerfile(platform)

        volumes_cmd = ''

        if volumes.kind_of?(Array)
          volumes.each do | volume |
            if not volume['guest']
              STDERR.puts "ERROR: Volume must have 'guest' parameter"
              exit!
            else
              if volume['host']
                volumes_cmd << "-v #{volume['host']}:#{volume['guest']} "
              else
                volumes_cmd << "-v #{volume['guest']} "
              end
            end
          end
        end

        puts "=== Create image ==="

        begin
          output = Admiral::Shell.local("docker -H #{docker} build --build-arg=USERNAME='#{username}' --build-arg=PASSWORD='#{password}' --no-cache -", {:input => dockerfile}, true)
        rescue Interrupt
            STDERR.puts "Creation interrupted"
            exit!
        end

        if output

          image_id = output.gsub(/.* /m, "")
          puts "Image ID : #{image_id}"

          Dir.mkdir(".states") unless File.exists?(".states")
          f = File.open(".states/#{platform_name}.image", "w")
          f.write("#{image_id}")
          f.close

          puts "=== Create container ==="
          container_id = Admiral::Shell.local("docker -H #{docker} run -d -p 22 -h #{hostname} --privileged --cap-add ALL #{volumes_cmd} #{image_id}")

          if container_id
            puts "Container ID : #{container_id}"
            Dir.mkdir(".states") unless File.exists?(".states")
            f = File.open(".states/#{platform_name}.container", "w")
            f.write("#{container_id}")
            f.close

            output = Admiral::Shell.local("docker  -H #{docker} inspect #{container_id}")
            if output
              ipaddress = extract_ipaddress(output)
              puts "=== Configuring container ==="
              success = self.apply_layers(platform, ipaddress)
              if not success
                STDERR.puts "Failed to apply configuration layers, run destroy"
                destroy(platform)
                exit!
              end
            else
              STDERR.puts "Failed to log in container, run destroy"
              destroy(platform)
              exit!
            end
          else
            STDERR.puts "Failed to create container, run destroy"
            destroy(platform)
            exit!
          end
        end
      end
    end

    def self.test (platform)
      platform_name = platform['name']
      testdir = "test"
      if Dir.exists?(testdir)
        puts "=== Run tests ==="
        container_id = get_container_id(platform['name'])
        docker = platform['docker']

        if container_id
          output = Admiral::Shell.local("docker  -H #{docker} inspect #{container_id}")
          if output
            ipaddress = extract_ipaddress(output)
            success = self.apply_test_layers(platform, ipaddress)
            if not success
              STDERR.puts "One or more tests failed, run destroy"
              destroy(platform)
              exit!
            end
          else
            STDERR.puts "Failed to get IP address"
            destroy(platform)
            exit!
          end
        else
          STDERR.puts "Failed to container ID"
          destroy(platform)
          exit!
        end
      else
        STDERR.puts "Test directory not found"
        destroy(platform)
        exit!
      end
    end

    def self.destroy (platform)
      platform_name = platform['name']
      docker = platform['docker']

      last_container_id = get_container_id(platform_name)
      if last_container_id
        puts "Remove container #{last_container_id}"
        Admiral::Shell.local("docker  -H #{docker} rm -f #{last_container_id}")
        File.delete(".states/#{platform_name}.container")
      else
        puts "No container"
      end

      last_image_id = get_image_id(platform_name)

      if last_container_id
        puts "Remove image #{last_image_id}"
        Admiral::Shell.local("docker  -H #{docker} rmi -f #{last_image_id}")
        File.delete(".states/#{platform_name}.image")
      else
        puts "No image"
      end
    end

    def self.login(platform)

      container_id = get_container_id(platform['name'])
      docker = platform['docker']

      if container_id
        output = Admiral::Shell.local("docker  -H #{docker} inspect #{container_id}")
        if output
          ipaddress = extract_ipaddress(output)
          username  = platform['username']
          keyfile   = platform['keyfile']
          cmd       = "/bin/bash"

          puts "Log in to #{ipaddress}"
          Admiral::Shell.remote(ipaddress, username, keyfile, cmd)
        else
          puts "Failed to get ip address"
        end
      else
         puts "No container"
      end
    end

    def self.get_image_id(platform_name)
       if File.exists?(".states/#{platform_name}.image")
          f = File.open(".states/#{platform_name}.image", "r")
          image_id = f.read()
          f.close
         return image_id
       else
         return nil
       end
    end

    def self.get_container_id(platform_name)
       if File.exists?(".states/#{platform_name}.container")
          f = File.open(".states/#{platform_name}.container", "r")
          container_id = f.read()
          f.close
         return container_id
       else
         return nil
       end
    end

    def self.apply_layers(platform, ipaddress)

      layers = platform['layers']

      layers.each do | layer_uid |
        begin
          require "admiral/layers/#{layer_uid}.rb"
        rescue LoadError
          STDERR.puts "Layer #{layer_uid} not found"
          return false
        end

        begin
          kclass = ::Admiral::Layers.const_get(Admiral::Layer.uid_to_name(layer_uid))
        rescue NameError
          STDERR.puts "Layer #{layer_uid} has mistake"
          return false
        end
        layer = kclass.new(platform,ipaddress)
        success = layer.run()

        if not success
          return false
        end
      end
      return true
    end

    def self.apply_test_layers(platform, ipaddress)

      layers = platform['tests']

      layers.each do | layer_uid |
        begin
          require "admiral/layers/#{layer_uid}.rb"
        rescue LoadError
          STDERR.puts "Layer #{layer_uid} not found"
          return false
        end

        begin
          kclass = ::Admiral::Layers.const_get(Admiral::Layer.uid_to_name(layer_uid))
        rescue NameError
          STDERR.puts "Layer #{layer_uid} has mistake"
          return false
        end
        layer = kclass.new(platform,ipaddress)
        success = layer.run()
        if not success
          return false
        end
      end
      return true
    end

    def self.generate_dockerfile(platform)
      image      = platform["image"]
      username   = platform['username']
      password   = platform['password']
      pubkeyfile = platform['pubkeyfile']
      registry   = platform['registry']

      begin
        f = File.open(pubkeyfile, 'r')
        public_key = f.read().chomp()
        f.close
      rescue Errno::ENOENT  => e
         STDERR.puts "Error with public key : #{e.message}"
         exit!
      end

      from = "FROM #{registry}/#{image}\n"

      user = <<-eos
        ARG USERNAME
        ARG PASSWORD
        RUN useradd -d /home/${USERNAME} -m -s /bin/bash ${USERNAME}
        RUN echo ${USERNAME}:${PASSWORD} | chpasswd
        RUN echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
      eos

      key = <<-eos
        RUN mkdir /home/${USERNAME}/.ssh
        RUN echo '#{public_key}' >> /home/${USERNAME}/.ssh/authorized_keys
      eos

      tmpdir = <<-eos
        RUN mkdir /tmp/${USERNAME}/
        RUN chown ${USERNAME}:${USERNAME} /tmp/${USERNAME}
      eos

      ssh_env = <<-eos
        RUN echo "AcceptEnv *" >> /etc/ssh/sshd_config
      eos

      [from, user, key, tmpdir, ssh_env].join("\n")
    end

    def self.extract_ipaddress(container_info)
      data  = YAML.load(container_info).first
      return data['NetworkSettings']['IPAddress']
    end

  end
end

