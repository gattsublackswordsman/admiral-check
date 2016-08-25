# -*- encoding: utf-8 -*-
#

require 'yaml'

module Admiral
  class Config
    attr_reader :platforms

    def initialize

      local_config_file = ".admiral.yml"
      global_config_file = File.expand_path("~/.admiral.yml")

      if not File.exist?(local_config_file)
        STDERR.puts "File .admiral.yml must be present"
        exit!
      end

      local_config = YAML.load_file(local_config_file)

      if  File.exist?(global_config_file)
        global_config = YAML.load_file(File.expand_path("~/.admiral.yml"))

        common_global_config = global_config['common']
        common_local_config  = local_config['common']

        if common_global_config.nil?
          if common_local_config.nil?
            STDERR.puts "No common config defined"
            exit!
          else
            common_config = common_local_config
          end
        else
          if common_local_config.nil?
            common_config = common_global_config
          else
            common_config = common_global_config.merge(common_local_config)
          end
        end
      else
        common_config = local_config['common']

        if common_config.nil?
          STDERR.puts "No common config defined"
          exit!
        end
      end

      @platforms = Hash.new
      @platforms_name = []
      @platforms_config = Hash.new

      common_applications = common_config['applications']
      common_applications = [] if not common_applications

      if local_config['platforms'].nil?
        STDERR.puts "No platforms defined"
        exit!
      end

      local_config['platforms'].each do | platform |
        platform_name = platform['name']
        @platforms[platform_name] = platform
        @platforms_name << platform_name

        @platforms_config[platform_name] = common_config.clone
        @platforms_config[platform_name].merge!(platform)

        platform_applications = @platforms_config[platform_name]['applications']
        platform_applications = [] if not platform_applications
        platform_applications_codes = []

        platform_applications.each do |application|
          platform_applications_codes << application['code']
        end

        common_applications.each do |application|
          if not platform_applications_codes.include?(application['code'])
             @platforms_config[platform_name]['applications'].push(application)
          end
        end
      end
    end

    def [](platform)
      return @platforms_config[platform]
    end

    def platform?(platform)
      return @platforms_config.key?(platform)
    end
  end
end
 
