#!/bin/env rake

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require "cct"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

Cct.setup(__dir__, verbose: verbose)
Cct.load_tasks!
