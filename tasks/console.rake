desc "Start console and load spider environment"
task :console do
  require 'irb'
  ARGV.clear
  log.info "Starting console (irb session)" 
  IRB.start
end
