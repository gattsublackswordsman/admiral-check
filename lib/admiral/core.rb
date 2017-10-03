require "thor"
require "admiral/docker"

module Admiral

  class Core < Thor

    def initialize(*args)
      super
      @config = Admiral::Config.new()
    end

    desc "list", "List available platforms"
    def list()
      platforms = @config.platforms
      platforms.keys.each do |  platform |
        puts "#{platform}"
      end
    end

    desc "create NAME", "Create a container for a platform"
    def create(platform_name)

       if  @config.platform?(platform_name)
         Admiral::Docker::verify(@config[platform_name])
         Admiral::Docker::create(@config[platform_name])
       else
         STDERR.puts "Platform #{platform_name} don't exist"
         exit!
       end
    end

    desc "apply-layer PLATFORM LAYER", "Apply a layer in an existing container"
    def apply_layer(platform_name, layer_uid)
      Admiral::Docker::verify((@config[platform_name]))

      if @config.platform?(platform_name)
        container_id = Admiral::Docker::get_container_id(platform_name)
        docker = @config[platform_name]['docker']
        if container_id
          ip_address = Admiral::Docker::get_ip_address(docker, container_id)
          if ip_address
            success = Admiral::Docker::apply_layer(@config[platform_name], layer_uid, ip_address)
            if not success
             STDERR.puts "failed to run the layer"
             exit!
            end
          else
            STDERR.puts "Failed to get IP address"
            exit!
          end
        else
          STDERR.puts "Failed to get container ID"
          exit!
        end
      else
        STDERR.puts "Platform #{platform_name} don't exist"
        exit!
      end
    end

    desc "login NAME", "Log in the container"
    def login(platform_name)
      Admiral::Docker::verify(@config[platform_name])
      Admiral::Docker::create(@config[platform_name])
      if  @config.platform?(platform_name)
        Admiral::Docker::login(@config[platform_name])
      else
        STDERR.puts "Platform #{platform_name} don't exist"
        exit!
      end
    end

    desc "test NAME", "Run the tests suite"
    def test(platform_name)
      if  @config.platform?(platform_name)
        Admiral::Docker::verify(@config[platform_name])
        Admiral::Docker::create(@config[platform_name])
        Admiral::Docker::test(@config[platform_name])
        Admiral::Docker::destroy(@config[platform_name])
      else
        STDERR.puts "Platform #{platform_name} don't exist"
        exit!
      end
    end

    desc "destroy NAME", "Destroy a container"
    def destroy(platform_name)
      if  @config.platform?(platform_name)
         Admiral::Docker::destroy(@config[platform_name])
       else
         STDERR.puts "Platform #{platform_name} don't exist"
         exit!
       end
    end

    desc "layer-info NAME", "Show informations about a layer"
    def layer_info(layer_uid)
      begin
        require "admiral/layers/#{layer_uid}.rb"
      rescue LoadError
        STDERR.puts "Layer #{layer_uid} not found"
        return false
      end

      begin
        kclass = ::Admiral::Layers.const_get(Admiral::Layer.uid_to_name(layer_uid))
      rescue NameError
        STDERR.puts "Layer #{layer_uid} has a mistake"
        return false
      end
      layer = kclass.new(nil, nil)
      layer.show_information
    end


    desc "config-help", "Show configuration help"
    def config_help()
      puts <<-EOF

  The configuration is located in .admiral.yml files.
  The global configuration is in ~/ and the local configuration is in any other directory.

  common:                                      # Configuration for all plaforms, in global or local configuration
      docker:     unix:///var/run/docker.sock  # Docker socket
      registry:   127.0.0.1:5000               # Docker registry
      username:   admiral                      # Username for Admiral user in the container
      password:   admiral                      # Password for Admiral
      keyfile:    docker_id_rsa                # Private Key for Admiral connection in the container
      pubkeyfile: docker_id_rsa.pub            # Associated public Key
      volumes:                                 # Optional, list of volumes to export in the container
       - guest: /path/in/the/guest             # Path of the volume in the container
         host:  /path/in/the/host              # Optional, path of the real directory
      layers:                                  # Layers for the configuration
        - admiral.svn.puppet.manifest
        - admiral.svn.puppet.cookbook
        - admiral.puppet.apply
      tests:                                   # Layers for the tests
        - admiral.test.chef.install
        - admiral.test.serverspec.install
        - admiral.test.serverspec.upload
        - admiral.test.serverspec.run

  platforms:                                   # List of platforms' configuration, only in local configuration
    - name:     my-server
      image:    ubuntu16                       # Docker image
      hostname: web.domain.lan
      lsp:      false                          # A layer parameter
      ...

EOF

    end
  end
end

