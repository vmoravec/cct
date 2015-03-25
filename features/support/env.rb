require "cct"
require "cct/cukes/world"

require_relative "step_helpers"

verbose = ARGV.grep(/(--verbose|-v)/).empty? ? false : true

Cct.setup(Dir.pwd, verbose)

World do
  Cct::Cukes::World.new
end

World(StepHelpers)
