module Cct
  module Cli
    def config
      require "awesome_print"
      Cct.setup(Pathname.new(__dir__).join("..").expand_path, verbose: false)

      ap Cct.config.content
    end

    def console
      require 'irb'
      require 'cct/cloud/world'

      Cct.setup(Pathname.new(__dir__).join("..").expand_path, verbose: false)
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

