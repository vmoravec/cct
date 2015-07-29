desc "Start console"
task :console do
  require 'irb'
  require 'cct/cloud/world'

  ARGV.clear
  Cct.update_logger(Cct::BaseLogger.new('console', stdout: true))
  cct.log.info "Starting console (irb session)" 

  # This brings various methods into the main scope of the IRB session;
  # It's very handy when testing things and playing with stuff
  self.extend(Module.new {
    WORLD = [:admin_node, :control_node, :nodes, :crowbar,
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
      WORLD
    end

    puts "Useful methods: #{WORLD.inspect}"
  })

  IRB.start(__FILE__)
end
