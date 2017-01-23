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
  headless.stop if respond_to?(:headless)
end

## Configuration for UI tests done by capybara gem

configure_ui_tests = !!ENV["cct_ui_tests"].to_s.match(/(1|true)/)

if configure_ui_tests
  begin
    Bundler.require(:ui_tests)
    require "capybara/cucumber"
    require "capybara-screenshot/cucumber"
  rescue LoadError
    puts "You need to run `bundle install --with ui_tests` to get the gems installed and loaded"
    exit 1
  end

  crowbar = Cct.config["admin_node"]

  # Creating X server virtual frame buffer; it's stopped in the `at_exit` block above
  headless = Headless.new
  headless.start

  # Having $WORKSPACE defined assumes a Jenkins build is running;
  # In case our test fails a file with name screenshot-YYYY-MM-DD-HH-MM-SS.MS.png is created
  # as well as copy of the html content is saved in the $WORKSPACE/.artifacts directory.
  # If no $WORKSPACE is defined, the files are created in current working dir
  Capybara.save_path = File.join(ENV["WORKSPACE"], ".artifacts") unless ENV["WORKSPACE"].to_s.empty?

  # Configure capybara to reach for the crowbar instance IP using webkit driver
  Capybara.configure do |config|
    config.default_driver = :webkit
    config.app_host =
      "http://#{crowbar["api"]["user"]}:#{crowbar["api"]["password"]}@#{crowbar["ip"]}"
  end

  Capybara::Webkit.configure do |config|
    config.allow_url(crowbar["ip"])
  end

  Capybara.default_max_wait_time = 5

  World(Capybara)
end
