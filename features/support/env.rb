require "cct"
require "cct/cukes/world"

verbose = ARGV.grep(/(--verbose|-v)/).empty? ? false : true

Cct.setup(Dir.pwd, verbose)

World do
  Cct::Cukes::World.new
end
