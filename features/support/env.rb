Bundler.require(:default)

require "cct/cloud/world"

require_relative "step_helpers"
require_relative "feature_helpers"
require_relative "custom_matchers"

# Guess verbosity from the cli params
verbose = ARGV.grep(/(--verbose|-v)/).empty? ? false : true

# Set the log path on the fly when need to redirect the log output (e.g. matrix)
log_path = ENV["cct_log_path"]

# Turn off the colored output if it was requested
Cucumber::Term::ANSIColor.coloring = false unless ENV['nocolor'].nil?

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

## Configuration for UI tests done by capybara gem

configure_ui_tests = !!ENV["cct_ui_tests"].to_s.match(/(1|true)/)

if configure_ui_tests
  begin
    Bundler.require(:ui_tests)
    require "capybara/cucumber"
  rescue LoadError
    puts "You need to run `bundle install --with ui_tests` to get the gems installed and loaded"
    exit 1
  end

  crowbar = Cct.config["admin_node"]

  Capybara.configure do |config|
    config.default_driver = :webkit
    config.app_host =
      "http://#{crowbar["api"]["user"]}:#{crowbar["api"]["password"]}@#{crowbar["ip"]}"
  end

  Capybara::Webkit.configure do |config|
    config.allow_url(crowbar["ip"])
  end

  World(Capybara)
end
