desc "Start console"
task :console do
  require 'irb'
  require 'cct/cukes/world'

  ARGV.clear
  Cct.instance_variable_set(:@logger, Cct::BaseLogger.new('console', stdout: true).base)
  log.info "Starting console (irb session)" 

  # This brings various methods into the main scope of the IRB session;
  # It's very handy when testing things and playing with stuff
  self.extend(Module.new {
    def cloud
      @cloud ||= Cct::Cukes::World.new
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
  })

  IRB.start(__FILE__)
end
