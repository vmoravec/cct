#!/bin/env rake

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require "cct"
require "cucumber"
require "cucumber/rake/task"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

Cct.setup(__dir__, verbose: verbose)

# Load all tasks by default from the directory 'tasks/'
Dir.glob(__dir__ + '/tasks/**/*.rake').each { |task| load(task) }
