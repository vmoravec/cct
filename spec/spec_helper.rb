$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'cct'

Cct.setup(__dir__ + "/..")

RSpec::Matchers.define :be_boolean do |expected|
  match do |actual|
    actual.is_a?(TrueClass) || actual.is_a?(FalseClass)
  end
end

