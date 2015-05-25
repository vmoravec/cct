desc "Forward remote cloud to localhost; use only if gate configuration available"
task :forward do
  ARGV.clear
  Cct.update_logger(Cct::BaseLogger.new('forward', stdout: true))
  cct.log.info "Forwarding remote cloud to localhost..." 
  if Cct.config.fetch("gate").nil?
    cct.log.error "No gate identified, nothing to forward"
    abort "Exiting.."
  end

  require 'cct/cloud/world'
  cloud = Cct::Cloud::World.new
  cloud.crowbar

  cct.log.info "Your testing cloud is available at http://localhost:3000"
  cct.log.info "Exit by Ctrl-C"

  trap('INT') do
    @interrupted = true
  end

  loop do
    if @interrupted
      cct.log.info "Closing socket for testing cloud... Exiting."
      exit 0
    end
  end
end
