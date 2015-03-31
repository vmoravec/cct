require "cct"
require "cct/cukes/world"

require_relative "step_helpers"

verbose = ARGV.grep(/(--verbose|-v)/).empty? ? false : true

Cct.setup(Dir.pwd, verbose)

log = Cct::BaseLogger.new("CUCUMBER", verbose)

log.info "Starting cucumber testsuite..."
log.info "`cucumber #{ARGV.join(" ")}`"

World do
  Cct::Cukes::World.new
end

World(StepHelpers)

Before do |scenario|
  log.info "Feature '#{scenario.feature}'"
  log.info "Running scenario '#{scenario.name}' in location `#{scenario.location}`"
end

After do |scenario|
  message = "Scenario '#{scenario.name}' #{scenario.failed? ? 'failed' : 'succeeded'}"
  log.info(message)  if scenario.passed?
  log.error(message) if scenario.failed?
end

at_exit do
  log.info "Exiting cucumber testsuite now..."
end
