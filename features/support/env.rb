require "cct"
require "cct/cloud/world"

require_relative "step_helpers"
require_relative "feature_helpers"

# Guess verbosity from the cli params
verbose = ARGV.grep(/(--verbose|-v)/).empty? ? false : true

# Set the log path on the fly when need to redirect the log output (e.g. matrix)
log_path = ENV["cct_log_path"]

# Turn off the colored output if it was requested
Cucumber::Term::ANSIColor.coloring = false unless ENV['nocolors'].nil?

Cct.setup(Dir.pwd, verbose: verbose, log_path: log_path)

log = Cct::BaseLogger.new("CUCUMBER", verbose: verbose, path: log_path)

log.info "Starting cucumber testsuite..."
log.info "`cucumber #{ARGV.join(" ")}`"

World do
  Cct::Cloud::World.new(log)
end

World(
  StepHelpers,
  FeatureHelpers
)


Before do |scenario|
  log.info "Feature '#{scenario.feature}'"
  filter_scenario_config_by(scenario.tags)
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
