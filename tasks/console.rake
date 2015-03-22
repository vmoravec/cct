desc "Start console"
task :console => :environment do
  require 'irb'
  ARGV.clear
  log.info "Starting console (irb session)" 
  IRB.start
end
