desc "Start console"
task :console do
  require 'irb'
  require 'cct/cukes/world'

  ARGV.clear
  log.info "Starting console (irb session)" 

  self.extend(Module.new {
    def cloud
      Cct::Cukes::World.new
    end
  })

  IRB.start(__FILE__)
end
