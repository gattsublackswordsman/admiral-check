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

    desc "create NAME", "Create a container for a platfom"
    def create(platform_name)
       if  @config.platform?(platform_name)
         Admiral::Docker::create(@config[platform_name])
       else
         STDERR.puts "Platform #{platform_name} don't exist"
         exit!         
       end
    end

    desc "login NAME", "Log in the container"
    def login(platform_name)
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
  end
end

