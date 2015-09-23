require 'rspec/expectations'

RSpec::Matchers.define :have_succeeded_at_least_once do
  match do |actual|
    succeeded = actual.select {|result| result.success? }
    succeeded.size.nonzero?
  end

  failure_message do |actual|
    "expected that #{actual} would contain at least one successful command result"
  end
end

RSpec::Matchers.define :match_with_output_at_least_once do |expected|
  match do |actual|
    outputs = actual.map(&:output).compact
    matches = outputs.map {|o| o.match(expected) }.compact
    matches.size.nonzero?
  end

  failure_message do |actual|
    "expected that at least one output value in #{actual} would match '#{expected}'"
  end
end
