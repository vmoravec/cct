module Cct
  module Cli

    def safely_parse
      yield
    rescue OptionParser::MissingArgument,
           OptionParser::InvalidOption => err
      abort "Error: #{err.message}"
    end

    def command name
      @commands ||= OpenStruct.new
      @commands[name] = yield if block_given?
    end

    def run_command name, options
      safely_parse { @commands[name].order! } if @commands[name]
      send(name, options)
    rescue NoMethodError => e
      puts e.backtrace if options.verbose
      abort "Unknown command '#{name}'"
    end

    # This method is in charge of starting cucumber and also setting up Cct
    def test options
      puts "Options given: #{options.to_h}" if options.verbose
      Dir.chdir(Pathname.new(File.join(__dir__, "../..")).expand_path) do |cct_dir|
        puts "Loading from #{cct_dir}"
        env = ""#File.exist?(LOCAL_CONFIG) ? "cct_config_file=#{LOCAL_CONFIG}" : ""
        command = "#{env} bundle exec cucumber --tags #{options.tags} #{'--verbose' if options.verbose}".strip
        puts command
        system(command)
      end
    end

    def config options
      require "awesome_print"
      Cct.setup(Pathname.new(__dir__).join("..").expand_path, verbose: false)

      ap Cct.config.content
    end

    def console options
      require 'irb'
      require 'cct/cloud/world'

      Cct.setup(Pathname.new(File.join(__dir__, "..", "..")).expand_path, verbose: false)
      ARGV.clear
      Cct.update_logger(Cct::BaseLogger.new('console', stdout: true))

      # This brings various methods into the main scope of the IRB session;
      # It's very handy when testing things and playing with stuff
      self.extend(Module.new {
        world = [:admin_node, :control_node, :nodes, :crowbar,
                 :config, :exec!, :openstack]

        def cloud
          @cloud ||= Cct::Cloud::World.new
        end

        def crowbar
          cloud.crowbar
        end

        def admin_node
          cloud.admin_node
        end

        def nodes
          cloud.nodes
        end

        def control_node
          cloud.control_node
        end

        def exec! *command
          cloud.exec!(*command)
        end

        def config
          cloud.config.content
        end

        def openstack
          cloud.control_node.openstack
        end

        def world
          world
        end

        puts "Useful methods: #{world.inspect}"
      })

      IRB.start(__FILE__)
    end
  end
end

