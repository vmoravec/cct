require "cct"
require "cct/cloud/world"

require_relative "step_helpers"

verbose = ARGV.grep(/(--verbose|-v)/).empty? ? false : true
log_path = ENV["cct_log_path"]

Cct.setup(Dir.pwd, verbose: verbose, log_path: log_path)

Cucumber::Term::ANSIColor.coloring = false unless ENV['nocolors'].nil?

log = Cct::BaseLogger.new("CUCUMBER", verbose: verbose, path: log_path)

log.info "Starting cucumber testsuite..."
log.info "`cucumber #{ARGV.join(" ")}`"

World do
  Cct::Cloud::World.new
end

World(StepHelpers)

Before do |scenario|
  log.info "Feature '#{scenario.feature}'"
  log.info "Running scenario '#{scenario.name}' found in `#{scenario.location}`"
end

After do |scenario|
  message = "Scenario '#{scenario.name}' "
  log.info(message  + "passed")  if scenario.passed?
  log.error(message + "failed")  if scenario.failed?
end

at_exit do
  log.info "Exiting cucumber testsuite now..."
end
