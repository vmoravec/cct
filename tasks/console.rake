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
    extend Forwardable

    def_delegators :@cloud, :exec!, :env

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
      cloud.nodes.control_node
    end

    methods = [:admin_node, :control_node, :nodes, :crowbar, :config, :exec!, :env, :cloud]

    puts "Useful methods: #{methods.inspect}"
  })

  IRB.start(__FILE__)
end
